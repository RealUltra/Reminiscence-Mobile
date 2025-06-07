import 'package:flutter/material.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';

class Body extends StatefulWidget {
  final ReminiscenceData data;

  const Body(this.data, {super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green);
  }
}
