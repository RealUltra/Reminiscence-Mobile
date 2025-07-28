import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/legal/privacy_policy_button.dart';
import 'package:reminiscence/ui/pages/settings/legal/terms_of_service_button.dart';

class LegalTile extends StatelessWidget {
  const LegalTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

      child: ExpansionTile(
        title: Text('Legal'),
        leading: Icon(Icons.gavel),
        children: [
          const SizedBox(height: 8.0),
          PrivacyPolicyButton(),
          TermsOfServiceButton(),
        ],
      ),
    );
  }
}
