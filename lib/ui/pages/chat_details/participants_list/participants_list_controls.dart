import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/components/toggle_button.dart';
import 'package:reminiscence/ui/pages/chat_details/enums.dart';

class ParticipantsListControls extends StatefulWidget {
  final ParticipantSortOption sortOption;
  final bool sortAscending;
  final ValueChanged<ParticipantSortOption> onSortOptionChanged;
  final ValueChanged<bool> onSortAscendingChanged;

  const ParticipantsListControls({
    super.key,
    required this.sortOption,
    required this.sortAscending,
    required this.onSortOptionChanged,
    required this.onSortAscendingChanged,
  });

  @override
  State<ParticipantsListControls> createState() =>
      ParticipantsListControlsState();
}

class ParticipantsListControlsState extends State<ParticipantsListControls> {
  late final SelectionController<int> sortController;
  late final SelectionController<int> orderController;

  @override
  void initState() {
    super.initState();

    sortController = SelectionController(_getSortIndex(widget.sortOption));
    orderController = SelectionController(widget.sortAscending ? 0 : 1);

    sortController.addListener(_onSortChanged);
    orderController.addListener(_onOrderChanged);
  }

  @override
  void didUpdateWidget(covariant ParticipantsListControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    sortController.setSelectedQuietly(_getSortIndex(widget.sortOption));
    orderController.setSelectedQuietly(widget.sortAscending ? 0 : 1);
  }

  @override
  void dispose() {
    sortController.removeListener(_onSortChanged);
    orderController.removeListener(_onOrderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildSortSelector(),
          const SizedBox(height: 8.0),
          _buildOrderSelector(),
        ],
      ),
    );
  }

  Widget _buildSortSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: ToggleButton(
          values: [
            ToggleButtonValue(
              icon: Icons.chat_bubble_outline_rounded,
              title: "Number of messages",
            ),
            ToggleButtonValue(icon: Icons.sort_by_alpha_rounded, title: "Name"),
          ],
          controller: sortController,
          decoration: _buildToggleButtonDecoration(context),
        ),
      ),
    );
  }

  Widget _buildOrderSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: ToggleButton(
          values: [
            ToggleButtonValue(
              icon: Icons.arrow_upward_rounded,
              title: "Ascending",
            ),
            ToggleButtonValue(
              icon: Icons.arrow_downward_rounded,
              title: "Descending",
            ),
          ],
          controller: orderController,
          decoration: _buildToggleButtonDecoration(context),
        ),
      ),
    );
  }

  int _getSortIndex(ParticipantSortOption option) {
    return option == ParticipantSortOption.messages ? 0 : 1;
  }

  ParticipantSortOption _getSortOption(int index) {
    return index == 0
        ? ParticipantSortOption.messages
        : ParticipantSortOption.name;
  }

  void _onSortChanged() {
    widget.onSortOptionChanged(_getSortOption(sortController.selected));
  }

  void _onOrderChanged() {
    widget.onSortAscendingChanged(orderController.selected == 0);
  }

  BoxDecoration _buildToggleButtonDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}
