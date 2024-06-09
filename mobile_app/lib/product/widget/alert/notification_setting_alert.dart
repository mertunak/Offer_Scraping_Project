import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/widget/buttons/custom_filled_button.dart';

class NotificationSettingAlert extends StatelessWidget {
  final double width;
  final double height;
  final OfferModel offerModel;

  const NotificationSettingAlert({
    Key? key,
    required this.width,
    required this.height,
    required this.offerModel,
  }) : super(key: key);

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
            const Text(
              "Kampanya Bitiş Bildirimi",
              style: TextStyles.MEDIUM,
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
                child: CustomDropdown(offerModel: offerModel),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CustomFilledButton(
                  backgroundColor: ButtonColors.PRIMARY_COLOR,
                  text: "Bildirim Oluştur",
                  textStyle: TextStyles.BUTTON,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final OfferModel offerModel;
  const CustomDropdown({
    Key? key,
    required this.offerModel,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final List<String> defaultList = <String>[
    "1 Gün Önce",
    "2 Gün Önce",
    "5 Gün Önce",
    "1 Hafta Önce",
    "Bildirim Gönderme"
  ];
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
      dropdownValue = '';
    } else if (differenceInDays <= 2) {
      dropdownValue = "1 Gün Önce";
    } else if (differenceInDays <= 5) {
      dropdownValue = "2 Gün Önce";
    } else if (differenceInDays <= 7) {
      dropdownValue = "5 Gün Önce";
    } else {
      dropdownValue = defaultList.first;
    }
  }

  Future<void> handleDropdownValue(String value) async {
    if (value == "Bildirim Gönderme") {
      print("No action needed for 'Send Notification'");
    } else {
      int? intValue = valueMap[value];
      // Your remaining code for handling dropdown value
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
          items: defaultList.map<DropdownMenuItem<String>>((String value) {
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
