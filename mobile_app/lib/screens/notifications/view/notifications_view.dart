import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/widget/list_tiles/notification_list_tile.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bildirimler"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        resizeToAvoidBottomInset: false,
        body: const Padding(
          padding: AppPaddings.MEDIUM_H,
          child: Column(
            children: <Widget>[
              NotificationListTile(title: "Notification 1", subtitle: "This is a notification"),
              NotificationListTile(title: "Notification 2", subtitle: "This is a notification"),
              NotificationListTile(title: "Notification 3", subtitle: "This is a notification"),
            ],
          ),
        ),
      ),
    );
  }
}
