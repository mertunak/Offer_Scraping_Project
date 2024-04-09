import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/widget/list_tiles/notification_list_tile.dart';

// ignore: must_be_immutable
class NotificationsView extends StatelessWidget {
  Map payload = {};

  NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    //for background and terminated state
    if (data is RemoteMessage) {
      payload = data.data;
    }

    //for foreground state
    if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bildirimler"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: AppPaddings.MEDIUM_H,
          child: Column(
            children: <Widget>[
              NotificationListTile(
                  title: "Notification 1", subtitle: "$payload.toString()"),
              const NotificationListTile(
                  title: "Notification 2", subtitle: "This is a notification"),
              const NotificationListTile(
                  title: "Notification 3", subtitle: "This is a notification"),
            ],
          ),
        ),
      ),
    );
  }
}
