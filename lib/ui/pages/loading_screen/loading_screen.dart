import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:reminiscence/ui/components/rotating_image.dart';
import 'package:reminiscence/ui/pages/loading_screen/progress.dart';

class LoadingScreen<T> extends StatefulWidget {
  final Function(List<dynamic>) operation;
  final List<dynamic> operationParams;
  final bool showProgress;
  final String? tooltip;

  const LoadingScreen({
    super.key,
    required this.operation,
    required this.operationParams,
    required this.showProgress,
    required this.tooltip,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState<T>();
}

class _LoadingScreenState<T> extends State<LoadingScreen> {
  late Progress progress;
  final _stopwatch = Stopwatch();
  String? duration;
  late bool isLoading;
  SendPort? sendPort;

  @override
  void initState() {
    super.initState();

    progress = Progress(value: 0);
    isLoading = true;

    startOperation();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, _) {
        sendPort?.send({"type": "cancel"});
      },
      child: Scaffold(
        appBar: null,

        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(bottom: 20),
            color: Theme.of(context).colorScheme.surfaceContainer,

            child: Center(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      RotatingImage(
                        image: Image.asset(
                          'assets/icon.png',
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (widget.showProgress) ...{
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 100),
                          child: LinearProgressIndicator(
                            value: progress.value,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 80),
                          child: Text(
                            (progress.label ?? "Loading, please wait..."),
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.8),
                          ),
                        ),
                      },
                    ],
                  ),

                  if (widget.tooltip != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,

                      child: Center(
                        child: Text(
                          widget.tooltip!,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> startOperation() async {
    final receivePort = ReceivePort();
    final rootToken = RootIsolateToken.instance!;

    _stopwatch.start();

    await Isolate.spawn(widget.operation, [
      ...widget.operationParams,
      rootToken,
      receivePort.sendPort,
    ]);

    receivePort.listen((message) async {
      if (message is! Map<String, dynamic>) return;

      if (message["type"] == "result") {
        final T? result = message["result"];
        final bool success = message["success"] ?? false;

        // In case the user cancelled.
        if (mounted && !success) {
          Navigator.pop(context, result);
          return;
        }

        // Set the duration and stop loading.
        if (mounted && success) {
          setState(() {
            duration = formatDuration(_stopwatch.elapsed);
            isLoading = false;
            debugPrint("Loading Screen Duration: $duration");
          });
        }

        if (mounted) {
          Navigator.pop(context, result);
        }
      } else if (message["type"] == "progress") {
        if (mounted) {
          setState(() {
            progress = Progress.fromMap(message["progress"]);
          });
        }
      } else if (message["type"] == "sendPort") {
        sendPort = message["sendPort"];
      }
    });
  }

  String formatDuration(Duration duration) {
    final durationStr = "${duration.inMilliseconds}";

    if (durationStr.length < 3) {
      return "0";
    }

    String secondsPart = durationStr.substring(0, durationStr.length - 3);
    secondsPart = secondsPart.isEmpty ? "0" : secondsPart;

    final millisecondsPart = durationStr.substring(durationStr.length - 3);

    return "$secondsPart.${millisecondsPart[0]}";
  }
}
