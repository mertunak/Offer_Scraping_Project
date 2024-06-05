import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/product/widget/buttons/custom_filled_button.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobile_app/services/notifications_service.dart';

class NotificationSettingAlert extends StatelessWidget {
  final double width;
  final double height;
  final OfferModel offerModel;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  NotificationSettingAlert({
    super.key,
    required this.width,
    required this.height,
    required this.offerModel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: AppPaddings.MEDIUM_H,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: AppPaddings.MEDIUM_H + AppPaddings.MEDIUM_V,
        decoration: BoxDecoration(
          color: SurfaceColors.PRIMARY_COLOR,
          borderRadius: AppBorderRadius.LARGE,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kampanya Bitiş Bildirimi",
                  style: TextStyles.MEDIUM,
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomDropdown(offerModel: offerModel),
              ],
            ),
            const ColumnDivider(verticalOffset: 10, horizontalOffset: 0),
            /* Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kampanya Alarmı",
                  style: TextStyles.MEDIUM,
                ),
                const SizedBox(
                  height: 5,
                ),
                alarmOptions(
                    dateController, "Tarih: __.__.____", true, context),
                const SizedBox(
                  height: 5,
                ),
                alarmOptions(timeController, "Zaman: __:__", false, context),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: CustomFilledButton(
                    backgroundColor: SurfaceColors.SECONDARY_COLOR,
                    text: "Alarm Ekle",
                    textStyle: TextStyle(
                      color: TextColors.BUTTON_TEXT_COLOR,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: () {
                      DateFormat dateFormat = DateFormat('dd.MM.yyyy');
                      DateTime parsedDate = dateFormat.parse(dateController.text);
                      DateFormat timeFormat = DateFormat('HH:mm');
                      DateTime parsedTime = timeFormat.parse(timeController.text);
                      DateTime combinedDateTime = DateTime(
                        parsedDate.year,
                        parsedDate.month,
                        parsedDate.day,
                        parsedTime.hour,
                        parsedTime.minute,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ) */
          ],
        ),
      ),
    );
  }

  Row alarmOptions(TextEditingController controller, String hint, bool isDate,
      BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 16,
          child: SizedBox(
            child: TextField(
              decoration: InputDecoration(
                contentPadding: AppPaddings.SMALL_H,
                enabled: false,
                disabledBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.MEDIUM,
                  borderSide: const BorderSide(
                    color: BorderColors.TEXTFIELD_COLOR,
                    width: 2,
                  ),
                ),
                hintText: hint,
                hintStyle: const TextStyle(color: TextColors.HINT_COLOR),
              ),
              controller: controller,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: AppBorderRadius.MEDIUM,
              child: Material(
                child: InkWell(
                  overlayColor: const MaterialStatePropertyAll(Colors.white10),
                  onTap: () async {
                    if (isDate) {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year),
                        lastDate: DateTime(DateTime.now().year + 5),
                        locale: Locale('tr'),
                      );
                      if (pickedDate != null) {
                        controller.text =
                            DateFormat('dd.MM.yyyy').format(pickedDate);
                      }
                    } else {
                      TimeOfDay? pickedTime = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (pickedTime != null) {
                        controller.text = TimeOfDay(
                                hour: pickedTime.hour,
                                minute: pickedTime.minute)
                            .format(context);
                      }
                    }
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      color: SurfaceColors.SECONDARY_COLOR,
                      borderRadius: AppBorderRadius.MEDIUM,
                    ),
                    child: const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          "Seç",
                          style: TextStyle(
                            color: TextColors.BUTTON_TEXT_COLOR,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final OfferModel offerModel;
  const CustomDropdown({
    super.key,
    required this.offerModel,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends BaseState<CustomDropdown> {
  final PushNotifications pushNotifications = PushNotifications();
  final List<String> list = <String>[
    "1 Gün Önce",
    "2 Gün Önce",
    "5 Gün Önce",
    "1 Hafta Önce",
    "Bildirim Gönderme"
  ];
  late String dropdownValue = list.first;
  final Map<String, int> valueMap = {
    "1 Gün Önce": 1,
    "2 Gün Önce": 2,
    "5 Gün Önce": 5,
    "1 Hafta Önce": 7,
  };
  Future<void> handleDropdownValue(String value) async {
    if (value == "Bildirim Gönderme") {
      // No action needed for "Send Notification"
      print("No action needed for 'Send Notification'");
    } else {
      // Get the corresponding integer value
      UserModel currentUser = UserManager.instance.currentUser;
      int? intValue = valueMap[value];
      String offerDate = widget.offerModel.endDate;
      DateFormat format = DateFormat("dd.MM.yyyy");
      DateTime endDate = format.parse(offerDate);
      DateTime scheduledDate = endDate.subtract(Duration(days: intValue!));
      String formattedDate = DateFormat("dd.MM.yyyy").format(scheduledDate);
      print("Selected integer value: $intValue");
      OfferNotificationModel offerNotificationModel = OfferNotificationModel(
        currentUser.id!,
        {
          widget.offerModel.id: {
            "notificationTime": intValue,
            "isNotified": false,
            "scheduledDate": formattedDate,
          }
        },
      );
      if (await FirestoreService().favOffersExists(currentUser.id!)) {
        await FirestoreService().addOrUpdateOfferData(offerNotificationModel);
      } else {
        await FirestoreService()
            .saveFavOfferNotification(offerNotificationModel);
      }
      await PushNotifications()
          .scheduleNotification(widget.offerModel, scheduledDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      expandedInsets: AppPaddings.MEDIUM_V,
      textStyle: TextStyles.SMALL,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: AppPaddings.SMALL_H,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.MEDIUM,
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: const MaterialStatePropertyAll(Colors.white),
        visualDensity: VisualDensity.standard,
        padding: const MaterialStatePropertyAll(EdgeInsets.zero),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AppBorderRadius.MEDIUM,
          ),
        ),
      ),
      initialSelection: list.first,
      onSelected: (String? value) async {
        dropdownValue = value!;
        print(dropdownValue);
        await handleDropdownValue(value);
      },
      dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
          style: ButtonStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: AppBorderRadius.MEDIUM,
            )),
            padding: MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        );
      }).toList(),
    );
  }
}
