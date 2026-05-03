import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry/create_password_title.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry/enter_password_title.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry/password_field.dart';
import 'package:reminiscence/ui/components/switch_controller.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry/submit_button.dart';

class PasswordEntryDialog extends StatefulWidget {
  /*
  * 0 -> Create Password
  * 1 -> Enter Password
  */
  final int mode;
  final Future<bool> Function(String password)? checkPassword;

  const PasswordEntryDialog(this.mode, {super.key, this.checkPassword});

  @override
  State<PasswordEntryDialog> createState() => _PasswordEntryDialogState();
}

class _PasswordEntryDialogState extends State<PasswordEntryDialog> {
  TextEditingController textController = TextEditingController();
  SwitchController switchController = SwitchController();

  bool failedAttempt = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    switchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.fromLTRB(12, 24, 12, 16),

          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,

            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              width: 1,
            ),

            borderRadius: BorderRadius.circular(16),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              widget.mode == 0 ? CreatePasswordTitle() : EnterPasswordTitle(),

              PasswordField(
                textController: textController,
                switchController: switchController,
                labelText:
                    widget.mode == 0 ? 'Password (Optional)' : 'Password',
              ),

              const SizedBox(height: 8),

              if (failedAttempt) ...{
                const SizedBox(height: 8),

                Text(
                  "Incorrect Password.",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              },

              const SizedBox(height: 16),

              SubmitButton(onClick: submitButtonPressed),
            ],
          ),
        ),
      ),
    );
  }

  void submitButtonPressed() async {
    final password = textController.text.trimRight();

    if (widget.checkPassword == null) {
      Navigator.of(context).pop(password);
      return;
    }

    final passwordIsCorrect = await widget.checkPassword!(password);

    if (!mounted) return;

    if (passwordIsCorrect) {
      Navigator.of(context).pop(password);
      return;
    }

    setState(() {
      textController.clear();
      failedAttempt = true;
    });
  }
}
