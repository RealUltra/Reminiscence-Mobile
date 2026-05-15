import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/about/version_tile.dart';

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

      child: ExpansionTile(
        title: const Text('About'),
        leading: const Icon(Icons.info),
        children: [const VersionTile()],
      ),
    );
  }
}
