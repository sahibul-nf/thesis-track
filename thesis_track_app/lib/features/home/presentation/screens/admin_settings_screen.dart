import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.bell),
                      title: const Text('Notifications'),
                      subtitle: const Text('Configure system notifications'),
                      trailing: const Icon(PhosphorIconsRegular.caretRight),
                      onTap: () {
                        // TODO: Implement notifications settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.calendar),
                      title: const Text('Academic Calendar'),
                      subtitle: const Text('Set academic year and important dates'),
                      trailing: const Icon(PhosphorIconsRegular.caretRight),
                      onTap: () {
                        // TODO: Implement calendar settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.clockClockwise),
                      title: const Text('Backup & Restore'),
                      subtitle: const Text('Manage system backup and restore'),
                      trailing: const Icon(PhosphorIconsRegular.caretRight),
                      onTap: () {
                        // TODO: Implement backup settings
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.info),
                      title: const Text('Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.database),
                      title: const Text('Database Status'),
                      subtitle: const Text('Connected'),
                      trailing: const Icon(
                        PhosphorIconsRegular.checkCircle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}