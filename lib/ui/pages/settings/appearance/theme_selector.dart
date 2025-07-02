import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/providers/theme_mode_provider.dart';

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({super.key});

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  final options = <String>["Default", "Light", "Dark"];
  final optionIcons = [Icons.settings, Icons.contrast, Icons.dark_mode];

  final themeModeValues = [null, "light", "dark"];

  late final SelectionController<int> controller;

  @override
  void initState() {
    super.initState();

    final themeModeProvider = Provider.of<ThemeModeProvider>(
      context,
      listen: false,
    );

    final currentThemeIndex = themeModeValues.indexOf(
      themeModeProvider.themeModeValue,
    );

    controller = SelectionController<int>(currentThemeIndex);

    controller.addListener(onThemeChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dark_mode),
      trailing: const Icon(Icons.chevron_right),

      title: Text(
        "Theme",
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),

      subtitle: Text(options[controller.selected]),

      onTap: () => _showOptions(context),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    final newMode = await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,

      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: List.generate(options.length, (index) {
              return ListTile(
                leading: Icon(optionIcons[index]),
                title: Text(options[index]),

                trailing:
                    (controller.selected == index) ? Icon(Icons.check) : null,

                onTap: () {
                  Navigator.of(context).pop(index);
                },
              );
            }),
          ),
        );
      },
    );

    if (newMode == null || !mounted) {
      return;
    }

    setState(() => controller.selected = newMode);
  }

  Future<void> onThemeChanged() async {
    final themeModeProvider = Provider.of<ThemeModeProvider>(
      context,
      listen: false,
    );

    await themeModeProvider.setThemeMode(themeModeValues[controller.selected]);
  }
}
