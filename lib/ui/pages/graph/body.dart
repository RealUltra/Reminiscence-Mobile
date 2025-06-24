import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/Graph.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';
import 'package:reminiscence/ui/pages/graph/header.dart';

class Body extends StatefulWidget {
  final GraphSettings graphSettings;
  final List<int> years;

  const Body({super.key, required this.graphSettings, required this.years});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,

        child: Column(
          children: [
            Header(settings: widget.graphSettings, years: widget.years),

            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(12.0, 16.0, 24.0, 16.0),

                child: Graph(settings: widget.graphSettings),
              ),
            ),

            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
