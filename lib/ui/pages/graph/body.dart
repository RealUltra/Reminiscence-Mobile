import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/header.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [Header()]));
  }
}
