import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/badge_layout.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_details_widget.dart';
import 'package:reminiscence/ui/pages/graph/graph_mode_dropdown.dart';
import 'package:reminiscence/ui/pages/graph/separate_participants_switch.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool isReady = false;

  final SwitchController switchController = SwitchController();
  final DropdownController modeController = DropdownController(initialValue: 1);
  final DropdownController detailsController = DropdownController(
    initialValue: -1,
  );

  late final List<int> timestamps;

  @override
  void initState() {
    super.initState();

    switchController.addListener(_updateWidgetSafely);

    modeController.addListener(() {
      if (mounted) {
        setState(() {
          detailsController.selected = -1;
        });
      }
    });

    detailsController.addListener(_updateWidgetSafely);

    fetchTimestamps();
  }

  Future<void> fetchTimestamps() async {
    final data = Provider.of<ReminiscenceData>(context, listen: false);
    final chat = Provider.of<ChatDto>(context, listen: false);

    timestamps = await data.db.messageDao.getMessageTimestamps(chat.id);

    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Container(color: Theme.of(context).colorScheme.surfaceContainer);
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.all(16.0),
      width: double.infinity,

      child: Column(
        children: [
          BadgeLayout(),

          const SizedBox(height: 24.0),

          GraphModeDropdown(controller: modeController),

          const SizedBox(height: 8.0),

          Visibility(
            visible: modeController.selected != 2,
            child: Container(
              margin: EdgeInsets.only(bottom: 8.0),
              child: GraphDetailsWidget(
                graphMode: modeController.selected,
                timestamps: timestamps,
                controller: detailsController,
              ),
            ),
          ),

          const SizedBox(height: 8.0),

          SeparateParticipantsSwitch(controller: switchController),
        ],
      ),
    );
  }

  void _updateWidgetSafely() {
    if (mounted) {
      setState(() {});
    }
  }
}
