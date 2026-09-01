import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
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
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppLanguage.tr('notif_page_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: Text(
                    AppLanguage.tr('notif_last_minute_title'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    AppLanguage.tr('notif_last_minute_desc'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  value: _lastMinuteEnabled,
                  activeColor: Colors.amber,
                  onChanged: (val) {
                    setState(() => _lastMinuteEnabled = val);
                    if (val) PushService.subscribeToLastMinute();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}