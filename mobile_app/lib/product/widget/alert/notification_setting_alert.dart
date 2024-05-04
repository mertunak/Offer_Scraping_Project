import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/widget/buttons/custom_filled_button.dart';
import 'package:mobile_app/product/widget/column_divider.dart';

class NotificationSettingAlert extends StatelessWidget {
  final double width;
  final double height;
  const NotificationSettingAlert({
    super.key,
    required this.width,
    required this.height,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kampanya Bitiş Bildirimi",
                  style: TextStyles.MEDIUM,
                ),
                SizedBox(
                  height: 5,
                ),
                CustomDropdown(),
              ],
            ),
            ColumnDivider(verticalOffset: 10, horizontalOffset: 0),
            CustomFilledButton(
                backgroundColor: SurfaceColors.SECONDARY_COLOR,
                text: "Hatırlatıcı Ekle",
                textStyle: TextStyles.BUTTON,
                onTap: () {})
          ],
        ),
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({
    super.key,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends BaseState<CustomDropdown> {
  final List<String> list = <String>[
    "1 Gün Önce",
    "2 Gün Önce",
    "5 Gün Önce",
    "1 Hafta Önce",
    "Bildirim Gönderme"
  ];
  late String dropdownValue = list.first;
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
      onSelected: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
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
