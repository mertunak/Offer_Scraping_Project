import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobile_app/services/notifications_service.dart';
import 'package:uuid/uuid.dart';

class CustomDropdown extends StatefulWidget {
  final OfferModel offerModel;
  final bool isUpdate;
  final OfferNotificationModel offerNotificationModel;
  const CustomDropdown({
    super.key,
    required this.offerModel,
    required this.isUpdate,
    required this.offerNotificationModel,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final PushNotifications pushNotifications = PushNotifications();
  final List<String> defaultList = <String>[
    "1 Gün Önce",
    "2 Gün Önce",
    "5 Gün Önce",
    "1 Hafta Önce",
    "Bildirim Gönderme"
  ];
  List<String> list = [];
  late String dropdownValue;
  final Map<String, int> valueMap = {
    "1 Gün Önce": 1,
    "2 Gün Önce": 2,
    "5 Gün Önce": 5,
    "1 Hafta Önce": 7,
  };

  @override
  void initState() {
    super.initState();
    updateDropdownOptions();
  }

  void updateDropdownOptions() {
    DateTime now = DateTime.now();
    String offerDate = widget.offerModel.endDate;
    DateFormat format = DateFormat("dd.MM.yyyy");
    DateTime endDate = format.parse(offerDate);

    int differenceInDays = endDate.difference(now).inDays;

    if (differenceInDays <= 1) {
      showAlertDialog(context);
      list = [];
    } else if (differenceInDays <= 2) {
      list = ["1 Gün Önce", "Bildirim Gönderme"];
    } else if (differenceInDays <= 5) {
      list = ["1 Gün Önce", "2 Gün Önce", "Bildirim Gönderme"];
    } else if (differenceInDays <= 7) {
      list = ["1 Gün Önce", "2 Gün Önce", "5 Gün Önce", "Bildirim Gönderme"];
    } else {
      list = defaultList;
    }

    dropdownValue = list.isNotEmpty ? list.first : '';
  }

  Future<void> handleDropdownValue(String value) async {
    if (value == "Bildirim Gönderme") {
      print("No action needed for 'Send Notification'");
    } else {
      UserModel currentUser = UserManager.instance.currentUser;
      int? intValue = valueMap[value];
      String offerDate = widget.offerModel.endDate;
      DateFormat format = DateFormat("dd.MM.yyyy");
      DateTime endDate = format.parse(offerDate);
      DateTime scheduledDate = DateTime.now().add(Duration(seconds: 10));
      //DateTime(endDate.year, endDate.month, endDate.day - intValue!, 9, 0, 0);
      String formattedDate =
          DateFormat("dd.MM.yyyy HH:mm").format(scheduledDate);

      if (scheduledDate.isBefore(DateTime.now())) {
        return showAlertDialog(context);
      } else {
        if (widget.isUpdate) {
          await FirestoreService().updateOfferNotification(
              currentUser.id!, widget.offerNotificationModel, intValue ?? 0);
        } else {
          OfferNotificationModel offerNotificationModel2 =
              OfferNotificationModel(
                  id: const Uuid().v4(),
                  offerID: widget.offerModel.id,
                  body: widget.offerModel.header,
                  title: widget.offerModel.site,
                  scheduledDate: formattedDate,
                  isNotified: false,
                  notificationTime: intValue ?? 0);
          FirestoreService()
              .saveToFirebase(currentUser.id!, offerNotificationModel2);
        }
        /*
        await PushNotifications()
            .scheduleNotification(widget.offerModel, scheduledDate); */
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: dropdownValue.isNotEmpty ? dropdownValue : null,
          onChanged: (String? value) async {
            if (value != null) {
              setState(() {
                dropdownValue = value;
              });
              await handleDropdownValue(value);
            }
          },
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlertDialog alert = AlertDialog(
        backgroundColor: SurfaceColors.PRIMARY_COLOR,
        title: Text("Hata!"),
        content: Text("Seçtiğiniz kampanyanın bitişine 1 gün kalmıştır."),
        actions: [
          TextButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    });
  }
}
