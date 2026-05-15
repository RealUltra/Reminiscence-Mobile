import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionTile extends StatelessWidget {
  const VersionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? 'v${snapshot.data!.version}' : '';

        return ListTile(
          leading: const Icon(Icons.tag),
          title: const Text("Version"),
          subtitle: Text(version),
        );
      },
    );
  }
}
