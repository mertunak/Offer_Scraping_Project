import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/core/base/view/base_view.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/screens/notifications/viewmodel/notifications_viewmodel.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends BaseState<NotificationsView> {
  late NotificationViewModel viewModel;
  @override
  void initState() {
    viewModel = NotificationViewModel();
    viewModel.getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<NotificationViewModel>(
      viewModel: NotificationViewModel(),
      onModelReady: (model) {
        model.setContext(context);
      },
      onPageBuilder: (context, value) => buildPage(context),
    );
  }

  Scaffold buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 15,
            child: Column(
              children: [
                Expanded(
                  flex: 14,
                  child: ListView.builder(
                    itemCount: viewModel.notificationsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      print(viewModel.notificationsList.length);
                      OfferNotificationModel offerNotificationModel =
                          viewModel.notificationsList[index];

                      return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ListTile(
                            title: Text(
                                offerNotificationModel.offerData.keys.first),
                            subtitle: Text(
                                offerNotificationModel.offerData.keys.last),
                          ));
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
