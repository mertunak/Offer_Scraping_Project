import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';

class ActiveNotificationsView extends StatefulWidget {
  final List<OfferNotificationModel> notifications;
  const ActiveNotificationsView({super.key, required this.notifications});

  @override
  State<ActiveNotificationsView> createState() =>
      _ActiveNotificationsViewState();
}

class _ActiveNotificationsViewState extends State<ActiveNotificationsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktif Bildirimler'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 15,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                OfferNotificationModel notification =
                    widget.notifications[index];
                String offerId = notification.offerData.keys.first;
                Map<String, dynamic> offerData =
                    notification.offerData[offerId]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.notifications_active,
                        color: ButtonColors.SECONDARY_COLOR,
                      ),
                      title: Text(
                        offerData['title'] ?? '',
                        style: TextStyles.SMALL,
                      ),
                      subtitle: Text(
                        offerData['body'] ?? '',
                        style: TextStyles.SMALL,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 57) +
                          AppPaddings.SMALL_V,
                      child: Text(
                        "Şu tarihte bildirilecek: ${offerData['scheduledDate']}",
                        style: TextStyles.TEXT_BUTTON,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
