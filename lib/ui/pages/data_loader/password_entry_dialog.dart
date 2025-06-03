import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/bullet_point.dart';

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
  bool failedAttempt = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          padding: EdgeInsets.fromLTRB(12, 24, 12, 12),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.mode == 0 ? _createPasswordText() : _enterPasswordText(),

              TextField(
                controller: textController,
                maxLines: 1,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelText: 'Password',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                  floatingLabelStyle: TextStyle(color: Colors.pinkAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (failedAttempt) const SizedBox(height: 8),
              if (failedAttempt)
                Text(
                  "Incorrect Password.",
                  style: TextStyle(color: Colors.redAccent),
                ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: submitButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Submit",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
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

  Widget _createPasswordText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Create Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),

        const SizedBox(height: 24),

        Text(
          "You're loading your raw Instagram data. To protect your data, please enter a password to encrypt it into a secure .rem file.",
        ),

        const SizedBox(height: 8),

        BulletPoint(
          "If you have already created a `.rem` file, please load it instead of the `.zip` file.",
        ),

        const SizedBox(height: 8),

        BulletPoint(
          "For added security, delete the `.zip` file after conversion.",
        ),

        const SizedBox(height: 8),

        BulletPoint(
          "Leave the password field empty if you don't want to encrypt your data.",
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _enterPasswordText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Enter Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),

        const SizedBox(height: 24),

        BulletPoint("This .rem file is password-protected."),

        BulletPoint(
          "If you do not remember your password, you must rebuild it from the .zip file.",
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
