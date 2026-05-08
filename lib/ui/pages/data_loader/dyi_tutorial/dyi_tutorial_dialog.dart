import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/message_box.dart';
import 'package:reminiscence/ui/pages/data_loader/dyi_tutorial/manual_body.dart';
import 'package:reminiscence/ui/pages/data_loader/dyi_tutorial/one_click_body.dart';
import 'package:reminiscence/ui/pages/data_loader/dyi_tutorial/switch_tab.dart';

class DyiTutorialDialog extends StatefulWidget {
  const DyiTutorialDialog({super.key});

  @override
  State<DyiTutorialDialog> createState() => _DyiTutorialDialogState();
}

class _DyiTutorialDialogState extends State<DyiTutorialDialog> {
  int activeTab = 0; // 0 = one-click, 1 = manual

  @override
  Widget build(BuildContext context) {
    return MessageBox(
      title: "Retrieve Your Data",
      body: Column(
        spacing: 32.0,

        children: [
          Row(
            spacing: 16.0,
            children: [
              SwitchTab(
                text: "One-Click",
                active: activeTab == 0,
                onTap: () => setState(() => activeTab = 0),
              ),
              SwitchTab(
                text: "In-App / Manual",
                onTap: () => setState(() => activeTab = 1),
                active: activeTab == 1,
              ),
            ],
          ),

          if (activeTab == 0) OneClickBody(),
          if (activeTab == 1) ManualBody(),
        ],
      ),

      actions: [MessageBoxButton("Done")],
    );
  }
}
