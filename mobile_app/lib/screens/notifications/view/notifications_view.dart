import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/core/base/view/base_view.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
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
            child: Observer(
              builder: (_) {
                return ListView.builder(
                  itemCount: viewModel.notificationsList.length,
                  itemBuilder: (context, index) {
                    OfferNotificationModel notification =
                        viewModel.notificationsList[index];
                    String offerId = notification.offerData.keys.first;
                    Map<String, dynamic> offerData =
                        notification.offerData[offerId]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.notifications),
                          title: Text(offerData['title'] ?? ''),
                          subtitle: Text(offerData['body'] ?? ''),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 57) +
                              AppPaddings.SMALL_V,
                          child: Text(
                              "Şu tarihte bildirildi: ${offerData['scheduledDate']}"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
