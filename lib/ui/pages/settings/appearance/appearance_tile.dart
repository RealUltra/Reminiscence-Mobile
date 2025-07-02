import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/appearance/theme_selector.dart';

class AppearanceTile extends StatelessWidget {
  const AppearanceTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

      child: ExpansionTile(
        title: Text('Appearance'),
        leading: Icon(Icons.color_lens),
        children: [ThemeSelector()],
      ),
    );
  }
}
