import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:reminiscence/ui/components/rotating_image.dart';
import 'package:reminiscence/ui/pages/loading_screen/progress.dart';

class LoadingScreen extends StatefulWidget {
  final Function(List<dynamic>) operation;
  final List<dynamic> operationParams;

  const LoadingScreen({
    super.key,
    required this.operation,
    required this.operationParams,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Progress progress;
  late final DateTime startTime;
  String? duration;
  late bool isLoading;
  SendPort? sendPort;

  @override
  void initState() {
    super.initState();

    progress = Progress(value: 0);
    startTime = DateTime.now();
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotatingImage(
                    image: Image.asset(
                      'assets/logo.png',
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100),
                    child: LinearProgressIndicator(
                      value: progress.value,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: Text(
                      isLoading
                          ? (progress.label ?? "Loading, please wait...")
                          : "Completed in $duration seconds.",
                      textAlign: TextAlign.center,
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

    await Isolate.spawn(widget.operation, [
      ...widget.operationParams,
      rootToken,
      receivePort.sendPort,
    ]);

    receivePort.listen((message) async {
      if (message is! Map<String, dynamic>) return;

      if (message["type"] == "result") {
        final String? result = message["result"];

        // In case the user cancelled.
        if (result == null) return;

        // Set the duration and stop loading.
        if (mounted) {
          setState(() {
            duration = formatDuration(DateTime.now().difference(startTime));
            debugPrint("Completed in $duration seconds.");
            isLoading = false;
          });
        }

        Future.delayed(Duration(seconds: 5)).then((_) {
          if (mounted) {
            Navigator.pop(context, result);
          }
        });
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

  Future<void> updateProgress(Progress progress) async {}

  String formatDuration(Duration duration) {
    final durationStr = "${duration.inMilliseconds}";
    final secondsPart = durationStr.substring(0, durationStr.length - 3);
    final millisecondsPart = durationStr.substring(durationStr.length - 3);
    return "$secondsPart.${millisecondsPart[0]}";
  }
}
