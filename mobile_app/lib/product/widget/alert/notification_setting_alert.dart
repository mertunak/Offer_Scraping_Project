import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/widget/buttons/custom_filled_button.dart';
import 'package:mobile_app/product/widget/custom_drop_down.dart';
import 'package:mobile_app/services/firestore.dart';

class NotificationSettingAlert extends StatefulWidget {
  final double width;
  final double height;
  final OfferModel offerModel;
  final OfferModel offer;
  List<OfferNotificationModel> notifications;

  NotificationSettingAlert({
    super.key,
    required this.width,
    required this.height,
    required this.offerModel,
    required this.notifications,
    required this.offer,
  });

  @override
  State<NotificationSettingAlert> createState() =>
      _NotificationSettingAlertState();
}

class _NotificationSettingAlertState extends State<NotificationSettingAlert> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: AppPaddings.MEDIUM_H,
      backgroundColor: Colors.transparent,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: AppPaddings.MEDIUM_H + AppPaddings.MEDIUM_V,
        decoration: BoxDecoration(
          color: SurfaceColors.PRIMARY_COLOR,
          borderRadius: AppBorderRadius.LARGE,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.notifications.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: widget.notifications.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                                title: Text(
                                    "${widget.notifications[index].notificationTime} gün önce bildirim gönderilecek."),
                                subtitle: Text(
                                  widget.notifications[index].scheduledDate
                                      .toString(),
                                  style: TextStyles.TEXT_BUTTON,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: ButtonColors.SECONDARY_COLOR,
                                  ),
                                  onPressed: () async {
                                    await FirestoreService()
                                        .deleteActiveNotification(
                                            UserManager
                                                .instance.currentUser.id!,
                                            widget.notifications[index]);
                                    widget.notifications =
                                        await FirestoreService()
                                            .offerActiveNotifications(
                                                UserManager
                                                    .instance.currentUser.id!,
                                                widget.offer.id);
                                    setState(() {});
                                  },
                                )),
                            Padding(
                              padding: AppPaddings.MEDIUM_H,
                              child: CustomDropdown(
                                offerModel: widget.offerModel,
                                isUpdate: true,
                                offerNotificationModel:
                                    widget.notifications[index],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: AppPaddings.MEDIUM_V + AppPaddings.SMALL_H,
                    child: const Center(
                      child: Column(
                        children: [
                          Text(
                            "Bu Kampanya için aktif bildirim ayarınız bulunmamaktadır.",
                            style: TextStyles.MEDIUM,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
            const Divider(),
            Padding(
              padding: AppPaddings.MEDIUM_H + AppPaddings.SMALL_V,
              child: const Center(
                child: Text(
                  "Yeni Bildirim Ayarı Ekle",
                  style: TextStyles.MEDIUM,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  maxWidth: double.infinity,
                ),
                child: Padding(
                    padding: AppPaddings.MEDIUM_H,
                    child: CustomDropdown(
                      isUpdate: false,
                      offerModel: widget.offerModel,
                      offerNotificationModel: OfferNotificationModel(
                        id: "",
                        offerID: "",
                        body: "",
                        title: "",
                        scheduledDate: "",
                        isNotified: false,
                        notificationTime: 0,
                      ),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CustomFilledButton(
                  backgroundColor: ButtonColors.PRIMARY_COLOR,
                  text: "Bildirim Oluştur",
                  textStyle: TextStyles.BUTTON,
                  onTap: () async {
                    widget.notifications = await FirestoreService()
                        .offerActiveNotifications(
                            UserManager.instance.currentUser.id!,
                            widget.offer.id);
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
