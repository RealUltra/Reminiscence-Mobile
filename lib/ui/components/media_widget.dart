import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

const double mediaAttachmentHeight = 300.0;
const double _mediaAttachmentMaxWidth = 400.0;
const double _inlineVideoControlsHeight = 76.0;
const double _thumbnailRailHeight = 112.0;
const int _videoInitializeMaxAttempts = 4;
const Duration _videoInitializeRetryDelay = Duration(milliseconds: 450);
const Duration _videoInitializeTimeout = Duration(seconds: 12);

enum MediaAttachmentType { photo, video }

class MediaAttachmentItem {
  final MediaAttachmentType type;
  final File file;
  final String fileName;
  final String mimeType;

  const MediaAttachmentItem({
    required this.type,
    required this.file,
    required this.fileName,
    required this.mimeType,
  });

  bool get isReady => file.existsSync() && file.lengthSync() > 0;

  bool get isPhoto => type == MediaAttachmentType.photo;

  bool get isVideo => type == MediaAttachmentType.video;

  String get heroTag => file.path;
}

final Map<String, _SharedVideoPlayback> _sharedVideoPlaybacks = {};

_SharedVideoPlayback _sharedPlaybackFor(MediaAttachmentItem item) {
  final key = item.file.path;
  final playback = _sharedVideoPlaybacks.putIfAbsent(
    key,
    () => _SharedVideoPlayback(key: key, item: item),
  );

  playback.updateItem(item);
  return playback;
}

class _SharedVideoPlayback extends ChangeNotifier {
  final String key;
  MediaAttachmentItem item;

  VideoPlayerController? controller;
  Timer? _retryTimer;
  Timer? _disposeTimer;
  int _initializeAttempt = 0;
  int _refCount = 0;
  bool _isInitializing = false;
  bool _isDisposed = false;

  _SharedVideoPlayback({required this.key, required this.item});

  bool get isReady => controller?.value.isInitialized == true;

  void updateItem(MediaAttachmentItem updatedItem) {
    item = updatedItem;

    if (controller == null && item.isReady) {
      unawaited(initializeIfNeeded());
    }
  }

  void retain() {
    if (_isDisposed) {
      return;
    }

    _refCount += 1;
    _disposeTimer?.cancel();
    _disposeTimer = null;
    unawaited(initializeIfNeeded());
  }

  void release() {
    if (_refCount > 0) {
      _refCount -= 1;
    }

    if (_refCount == 0) {
      _disposeTimer?.cancel();
      _disposeTimer = Timer(const Duration(seconds: 20), dispose);
    }
  }

  Future<void> initializeIfNeeded() async {
    if (_isDisposed || _isInitializing || controller != null || !item.isReady) {
      return;
    }

    _isInitializing = true;
    _retryTimer?.cancel();

    final nextController = VideoPlayerController.file(item.file);
    controller = nextController;
    nextController.addListener(_handleControllerUpdate);
    notifyListeners();

    try {
      await nextController.initialize().timeout(_videoInitializeTimeout);
    } catch (_) {
      nextController.removeListener(_handleControllerUpdate);
      nextController.dispose();

      if (controller == nextController) {
        controller = null;
      }

      _isInitializing = false;
      _scheduleInitializationRetry();
      notifyListeners();
      return;
    }

    if (_isDisposed || controller != nextController) {
      nextController.removeListener(_handleControllerUpdate);
      nextController.dispose();
      _isInitializing = false;
      return;
    }

    _initializeAttempt = 0;
    _isInitializing = false;
    notifyListeners();
  }

  void _handleControllerUpdate() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _scheduleInitializationRetry() {
    if (_isDisposed ||
        !item.isReady ||
        _initializeAttempt >= _videoInitializeMaxAttempts) {
      return;
    }

    _initializeAttempt += 1;
    final retryDelay = Duration(
      milliseconds:
          _videoInitializeRetryDelay.inMilliseconds * _initializeAttempt,
    );
    _retryTimer?.cancel();
    _retryTimer = Timer(retryDelay, () {
      if (!_isDisposed) {
        unawaited(initializeIfNeeded());
      }
    });
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _retryTimer?.cancel();
    _disposeTimer?.cancel();

    final oldController = controller;
    controller = null;

    if (oldController != null) {
      oldController.removeListener(_handleControllerUpdate);
      oldController.dispose();
    }

    if (identical(_sharedVideoPlaybacks[key], this)) {
      _sharedVideoPlaybacks.remove(key);
    }

    super.dispose();
  }
}

class MediaWidget extends StatelessWidget {
  final List<MediaAttachmentItem> items;

  const MediaWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _mediaAttachmentMaxWidth),
        child: SizedBox(
          height: mediaAttachmentHeight,
          width: double.infinity,
          child:
              items.length == 1
                  ? _SingleMediaPreview(item: items.first, allItems: items)
                  : _MediaStack(items: items),
        ),
      ),
    );
  }
}

class _SingleMediaPreview extends StatelessWidget {
  final MediaAttachmentItem item;
  final List<MediaAttachmentItem> allItems;

  const _SingleMediaPreview({required this.item, required this.allItems});

  @override
  Widget build(BuildContext context) {
    if (item.isVideo) {
      return _InlineVideoPlayer(
        item: item,
        allItems: allItems,
        initialIndex: 0,
        showAlbumBadge: false,
      );
    }

    return _PhotoTile(
      item: item,
      fit: BoxFit.contain,
      onTap: item.isReady ? () => _openViewer(context, allItems, 0) : null,
    );
  }
}

class _MediaStack extends StatelessWidget {
  final List<MediaAttachmentItem> items;

  const _MediaStack({required this.items});

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(3).toList();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var index = visibleItems.length - 1; index >= 0; index--)
          _StackedMediaCard(
            item: visibleItems[index],
            index: index,
            totalItems: items.length,
            allItems: items,
          ),
      ],
    );
  }
}

class _StackedMediaCard extends StatelessWidget {
  final MediaAttachmentItem item;
  final int index;
  final int totalItems;
  final List<MediaAttachmentItem> allItems;

  const _StackedMediaCard({
    required this.item,
    required this.index,
    required this.totalItems,
    required this.allItems,
  });

  @override
  Widget build(BuildContext context) {
    final inset = index * 10.0;
    final isFrontCard = index == 0;

    return Positioned(
      left: inset,
      top: inset,
      right: (2 - index).clamp(0, 2).toDouble() * 10.0,
      bottom: (2 - index).clamp(0, 2).toDouble() * 10.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 18.0,
              offset: const Offset(0, 8.0),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isFrontCard && item.isVideo)
              _InlineVideoPlayer(
                item: item,
                allItems: allItems,
                initialIndex: index,
                showAlbumBadge: true,
                totalItems: totalItems,
              )
            else if (item.isPhoto)
              _PhotoTile(
                item: item,
                fit: BoxFit.cover,
                onTap:
                    item.isReady
                        ? () => _openViewer(context, allItems, index)
                        : null,
              )
            else
              _VideoPosterTile(
                item: item,
                onTap:
                    item.isReady
                        ? () => _openViewer(context, allItems, index)
                        : null,
              ),

            if (isFrontCard && !item.isVideo)
              Positioned(
                left: 12.0,
                bottom: 12.0,
                child: _MediaCountBadge(totalItems: totalItems),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final MediaAttachmentItem item;
  final BoxFit fit;
  final VoidCallback? onTap;

  const _PhotoTile({
    required this.item,
    required this.fit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _MediaCardShell(
      onTap: onTap,
      child:
          item.isReady
              ? Hero(
                tag: item.heroTag,
                child: Image.file(
                  item.file,
                  fit: fit,
                  errorBuilder: (context, _, _) => const _MediaError(),
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _VideoPosterTile extends StatelessWidget {
  final MediaAttachmentItem item;
  final VoidCallback? onTap;

  const _VideoPosterTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _MediaCardShell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF151515), Color(0xFF050505)],
              ),
            ),
          ),
          Center(
            child:
                item.isReady
                    ? const _PlayBadge(size: 62.0)
                    : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _MediaCardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _MediaCardShell({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.50),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const SizedBox(height: 72.0),
                ),
              ),
              Positioned(
                right: 10.0,
                bottom: 10.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.46),
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final MediaAttachmentItem item;
  final List<MediaAttachmentItem> allItems;
  final int initialIndex;
  final bool showAlbumBadge;
  final int? totalItems;

  const _InlineVideoPlayer({
    required this.item,
    required this.allItems,
    required this.initialIndex,
    required this.showAlbumBadge,
    this.totalItems,
  });

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  final controlsDisplayDuration = const Duration(seconds: 5);

  _SharedVideoPlayback? _playback;
  Timer? _hideTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _attachPlayback();
  }

  @override
  void didUpdateWidget(covariant _InlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.file.path != widget.item.file.path) {
      _detachPlayback();
      _attachPlayback();
      return;
    }

    _playback?.updateItem(widget.item);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _detachPlayback();
    super.dispose();
  }

  void _attachPlayback() {
    final playback = _sharedPlaybackFor(widget.item);
    playback.retain();
    playback.addListener(_handlePlaybackUpdate);
    _playback = playback;
  }

  void _detachPlayback() {
    final playback = _playback;
    if (playback == null) {
      return;
    }

    playback.removeListener(_handlePlaybackUpdate);
    playback.release();
    _playback = null;
  }

  void _handlePlaybackUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final playback = _playback;
    final controller = playback?.controller;
    final isReady = playback?.isReady == true;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: Material(
        color: Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlayback,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isReady && controller != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

              if (isReady && controller != null && !controller.value.isPlaying)
                const Center(
                  child: IgnorePointer(child: _PlayBadge(size: 68.0)),
                ),

              if (_showControls ||
                  controller == null ||
                  !controller.value.isPlaying)
                _InlineVideoControls(
                  controller: controller,
                  onPlayPause: () async {
                    if (controller == null) return;
                    controller.value.isPlaying ? await _pause() : await _play();
                  },
                  onShare: widget.item.isReady ? _shareCurrentVideo : null,
                  onFullScreen: widget.item.isReady ? _openFullScreen : null,
                ),

              if (widget.showAlbumBadge && widget.totalItems != null)
                Positioned(
                  left: 12.0,
                  bottom: _inlineVideoControlsHeight + 8.0,
                  child: _MediaCountBadge(totalItems: widget.totalItems!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _play() async {
    final controller = _playback?.controller;
    if (controller == null || _playback?.isReady != true) return;

    await controller.play();
    if (!mounted) return;

    _showControlsTemporarily();
  }

  Future<void> _pause() async {
    final controller = _playback?.controller;
    if (controller == null || _playback?.isReady != true) return;

    await controller.pause();
    _hideTimer?.cancel();
    if (mounted) {
      setState(() => _showControls = true);
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _playback?.controller;
    if (controller == null || _playback?.isReady != true) return;

    controller.value.isPlaying ? await _pause() : await _play();
  }

  void _showControlsTemporarily() {
    if (!mounted) return;

    _hideTimer?.cancel();
    setState(() => _showControls = true);

    _hideTimer = Timer(controlsDisplayDuration, () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  Future<void> _shareCurrentVideo() async {
    await _shareMediaItem(context, widget.item);
  }

  Future<void> _openFullScreen() async {
    if (mounted) {
      await _openViewer(context, widget.allItems, widget.initialIndex);
    }

    if (!mounted) return;

    final controller = _playback?.controller;
    if (controller?.value.isPlaying == true) {
      _showControlsTemporarily();
    } else {
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    }
  }
}

class _InlineVideoControls extends StatelessWidget {
  final VideoPlayerController? controller;
  final VoidCallback onPlayPause;
  final VoidCallback? onShare;
  final VoidCallback? onFullScreen;

  const _InlineVideoControls({
    required this.controller,
    required this.onPlayPause,
    required this.onShare,
    required this.onFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller?.value;
    final position = value?.position ?? Duration.zero;
    final duration = value?.duration ?? Duration.zero;
    final max =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final sliderValue =
        position.inMilliseconds.clamp(0, max.toInt()).toDouble();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: _inlineVideoControlsHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.82),
                Colors.black.withValues(alpha: 0.48),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 2.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0),
                  ),
                  child: Slider(
                    value: sliderValue,
                    max: max,
                    padding: EdgeInsets.zero,
                    onChanged:
                        controller == null
                            ? null
                            : (value) {
                              controller!.seekTo(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                  ),
                ),
                SizedBox(
                  height: 40.0,
                  child: Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: controller == null ? null : onPlayPause,
                        color: Colors.white,
                        icon: Icon(
                          value?.isPlaying == true
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${_formatDuration(position)} / ${_formatDuration(duration)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onShare,
                        color: Colors.white,
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onFullScreen,
                        color: Colors.white,
                        icon: const Icon(Icons.fullscreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaViewer extends StatefulWidget {
  final List<MediaAttachmentItem> items;
  final int initialIndex;

  const _MediaViewer({required this.items, required this.initialIndex});

  @override
  State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  MediaAttachmentItem get _currentItem => widget.items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = widget.items[index];

              if (item.isPhoto) {
                return _ViewerPhotoPage(item: item);
              }

              return _ViewerVideoPage(
                item: item,
                isActive: index == _currentIndex,
                reserveThumbnailRail: widget.items.length > 1,
              );
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MediaViewerTopBar(
              currentIndex: _currentIndex,
              totalItems: widget.items.length,
              onClose: () => Navigator.of(context).pop(),
              onShare:
                  _currentItem.isReady
                      ? () async => _shareMediaItem(context, _currentItem)
                      : null,
            ),
          ),

          if (widget.items.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _MediaViewerThumbnailStrip(
                items: widget.items,
                currentIndex: _currentIndex,
                onSelected: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewerPhotoPage extends StatelessWidget {
  final MediaAttachmentItem item;

  const _ViewerPhotoPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 5.0,
      child: Center(
        child:
            item.isReady
                ? Hero(
                  tag: item.heroTag,
                  child: Image.file(
                    item.file,
                    fit: BoxFit.contain,
                    errorBuilder: (context, _, _) => const _MediaError(),
                  ),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}

class _ViewerVideoPage extends StatefulWidget {
  final MediaAttachmentItem item;
  final bool isActive;
  final bool reserveThumbnailRail;

  const _ViewerVideoPage({
    required this.item,
    required this.isActive,
    required this.reserveThumbnailRail,
  });

  @override
  State<_ViewerVideoPage> createState() => _ViewerVideoPageState();
}

class _ViewerVideoPageState extends State<_ViewerVideoPage> {
  _SharedVideoPlayback? _playback;

  @override
  void initState() {
    super.initState();
    _attachPlayback();
  }

  @override
  void didUpdateWidget(covariant _ViewerVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.file.path != widget.item.file.path) {
      _detachPlayback();
      _attachPlayback();
      return;
    }

    _playback?.updateItem(widget.item);

    if (oldWidget.isActive && !widget.isActive) {
      unawaited(_pauseBecauseInactive());
    }
  }

  @override
  void dispose() {
    _detachPlayback();
    super.dispose();
  }

  void _attachPlayback() {
    final playback = _sharedPlaybackFor(widget.item);
    playback.retain();
    playback.addListener(_handlePlaybackUpdate);
    _playback = playback;
  }

  void _detachPlayback() {
    final playback = _playback;
    if (playback == null) {
      return;
    }

    playback.removeListener(_handlePlaybackUpdate);
    playback.release();
    _playback = null;
  }

  void _handlePlaybackUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final playback = _playback;
    final controller = playback?.controller;

    if (playback?.isReady != true || controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlayback,
          child: Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        if (!controller.value.isPlaying)
          const Center(child: IgnorePointer(child: _PlayBadge(size: 76.0))),
        Positioned(
          left: 0,
          right: 0,
          bottom:
              widget.isActive
                  ? (widget.reserveThumbnailRail
                      ? _thumbnailRailHeight - 12.0
                      : 0.0)
                  : -160.0,
          child: _ViewerVideoControls(controller: controller),
        ),
      ],
    );
  }

  Future<void> _togglePlayback() async {
    final controller = _playback?.controller;
    if (controller == null || _playback?.isReady != true) return;

    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
  }

  Future<void> _pauseBecauseInactive() async {
    final controller = _playback?.controller;
    if (controller == null || _playback?.isReady != true) return;

    await controller.pause();
  }
}

class _ViewerVideoControls extends StatelessWidget {
  final VideoPlayerController controller;

  const _ViewerVideoControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    final max =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final sliderValue =
        position.inMilliseconds.clamp(0, max.toInt()).toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.78), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 34.0, 16.0, 14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 2.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
                ),
                child: Slider(
                  value: sliderValue,
                  max: max,
                  padding: EdgeInsets.zero,
                  onChanged: (value) {
                    controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
              Row(
                children: [
                  IconButton.filled(
                    style: _viewerIconButtonStyle(),
                    onPressed: () {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      "${_formatDuration(position)} / ${_formatDuration(duration)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaViewerTopBar extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final VoidCallback onClose;
  final VoidCallback? onShare;

  const _MediaViewerTopBar({
    required this.currentIndex,
    required this.totalItems,
    required this.onClose,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.78), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 28.0),
          child: Row(
            children: [
              _ViewerIconButton(icon: Icons.close, onPressed: onClose),
              Expanded(
                child: Text(
                  "${currentIndex + 1} / $totalItems",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ViewerIconButton(icon: Icons.share, onPressed: onShare),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaViewerThumbnailStrip extends StatefulWidget {
  final List<MediaAttachmentItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _MediaViewerThumbnailStrip({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  State<_MediaViewerThumbnailStrip> createState() =>
      _MediaViewerThumbnailStripState();
}

class _MediaViewerThumbnailStripState
    extends State<_MediaViewerThumbnailStrip> {
  late List<GlobalKey> _thumbnailKeys;

  @override
  void initState() {
    super.initState();
    _thumbnailKeys = _buildThumbnailKeys();
    _scrollSelectedThumbnailIntoView();
  }

  @override
  void didUpdateWidget(covariant _MediaViewerThumbnailStrip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      _thumbnailKeys = _buildThumbnailKeys();
    }

    if (oldWidget.currentIndex != widget.currentIndex ||
        oldWidget.items.length != widget.items.length) {
      _scrollSelectedThumbnailIntoView();
    }
  }

  List<GlobalKey> _buildThumbnailKeys() {
    return List.generate(widget.items.length, (_) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.78), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _thumbnailRailHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16.0, 22.0, 16.0, 18.0),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10.0),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final selected = index == widget.currentIndex;

              return GestureDetector(
                onTap: item.isReady ? () => widget.onSelected(index) : null,
                child: AnimatedContainer(
                  key: _thumbnailKeys[index],
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: selected ? 72.0 : 62.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color:
                          selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.28),
                      width: selected ? 2.0 : 1.0,
                    ),
                    boxShadow:
                        selected
                            ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.22),
                                blurRadius: 18.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                            : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: _MediaThumbnail(item: item),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _scrollSelectedThumbnailIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.currentIndex >= _thumbnailKeys.length) {
        return;
      }

      final context = _thumbnailKeys[widget.currentIndex].currentContext;

      if (context == null) {
        return;
      }

      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _MediaThumbnail extends StatelessWidget {
  final MediaAttachmentItem item;

  const _MediaThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    if (!item.isReady) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (item.isPhoto) {
      return Image.file(item.file, fit: BoxFit.cover);
    }

    return const ColoredBox(
      color: Colors.black,
      child: Center(child: Icon(Icons.play_arrow, color: Colors.white)),
    );
  }
}

class _MediaCountBadge extends StatelessWidget {
  final int totalItems;

  const _MediaCountBadge({required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.collections, color: Colors.white, size: 16.0),
            const SizedBox(width: 6.0),
            Text(
              "$totalItems media",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  final double size;

  const _PlayBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: SizedBox(
        height: size,
        width: size,
        child: Icon(Icons.play_arrow, color: Colors.white, size: size * 0.56),
      ),
    );
  }
}

class _ViewerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _ViewerIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: _viewerIconButtonStyle(),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _MediaError extends StatelessWidget {
  const _MediaError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.broken_image, color: Colors.white70, size: 42.0),
    );
  }
}

ButtonStyle _viewerIconButtonStyle() {
  return IconButton.styleFrom(
    backgroundColor: Colors.white.withValues(alpha: 0.14),
    foregroundColor: Colors.white,
    disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
    disabledForegroundColor: Colors.white.withValues(alpha: 0.32),
  );
}

Future<void> _openViewer(
  BuildContext context,
  List<MediaAttachmentItem> items,
  int initialIndex,
) async {
  await Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              _MediaViewer(items: items, initialIndex: initialIndex),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

Future<void> _shareMediaItem(
  BuildContext context,
  MediaAttachmentItem item,
) async {
  try {
    final shareFile = await _copyToShareFile(item);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(shareFile.path, name: item.fileName, mimeType: item.mimeType),
        ],
      ),
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            "Could not share this media.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }
}

Future<File> _copyToShareFile(MediaAttachmentItem item) async {
  final tempDir = await getTemporaryDirectory();
  final sharePath = p.join(tempDir.path, item.fileName);

  return item.file.copy(sharePath);
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
