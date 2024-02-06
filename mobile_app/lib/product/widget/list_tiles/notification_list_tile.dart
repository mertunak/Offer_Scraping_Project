import 'package:flutter/material.dart';

class NotificationListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const NotificationListTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications_sharp),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
