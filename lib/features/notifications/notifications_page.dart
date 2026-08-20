import 'package:flutter/material.dart';
import '../../core/services/push_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _lastMinuteEnabled = true;

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Értesítések Beállítása', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Last Minute Akciók', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Értesítsen, ha villámakciók érhetőek el', style: TextStyle(color: Colors.white70)),
              value: _lastMinuteEnabled,
              onChanged: (val) {
                setState(() => _lastMinuteEnabled = val);
                if (val) PushService.subscribeToLastMinute();
              },
            ),
          ],
        ),
      ),
    );
  }
}