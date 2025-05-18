import 'package:flutter/material.dart';

class PasswordEntryDialog extends StatefulWidget {
  const PasswordEntryDialog({super.key});

  @override
  State<PasswordEntryDialog> createState() => _PasswordEntryDialogState();
}

class _PasswordEntryDialogState extends State<PasswordEntryDialog> {
  TextEditingController textController = TextEditingController();

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
              Text(
                "Create Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),

              const SizedBox(height: 24),

              Text(
                "You're loading your raw Instagram data. To protect your data, please enter a password to encrypt it into a secure .rem file.",
              ),

              const SizedBox(height: 8),

              _buildBulletPoint(
                "If you have already created a `.rem` file, please load it instead of the `.zip` file.",
              ),

              const SizedBox(height: 8),

              _buildBulletPoint(
                "For added security, delete the `.zip` file after conversion.",
              ),

              const SizedBox(height: 8),

              _buildBulletPoint(
                "Leave the password field empty if you don't want to encrypt your data.",
              ),

              const SizedBox(height: 24),

              TextField(
                controller: textController,
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelText: 'Password',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                  floatingLabelStyle: TextStyle(color: Colors.pinkAccent),
                ),
              ),

              const SizedBox(height: 24),

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

  void submitButtonPressed() {
    final password = textController.text.trimRight();
    Navigator.of(context).pop(password);
  }

  Widget _buildBulletPoint(String text, {TextStyle? textStyle}) {
    textStyle ??= TextStyle();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("•  ", style: textStyle.copyWith(fontSize: 20, height: 1.1)),
          Expanded(
            child: Text(
              text,
              style: textStyle.copyWith(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
