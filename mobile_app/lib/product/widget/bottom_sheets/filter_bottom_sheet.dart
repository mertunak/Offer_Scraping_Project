// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/widget/buttons/custom_filled_button.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/product/widget/filter_component/filter_multiple_checkbox.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';

import '../../constants/utils/color_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final OfferViewModel viewModel;
  final TextEditingController leastPriceController;
  final TextEditingController mostPriceController;
  const FilterBottomSheet(
      {required this.leastPriceController,
      required this.mostPriceController,
      required this.viewModel,
      super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends BaseState<FilterBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dynamicHeightDevice(0.8),
      decoration: const BoxDecoration(
        color: SurfaceColors.PRIMARY_COLOR,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: AppPaddings.MEDIUM_V + AppPaddings.MEDIUM_H,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: SortByWidget(
                      isSelected: widget.viewModel.isSelected,
                    ),
                  ),
                  ColumnDivider(verticalOffset: 5, horizontalOffset: 0),
                  Expanded(
                    flex: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Filtreleme",
                          style: TextStyle(
                            color: TextColors.PRIMARY_COLOR,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // FilterMultipleCheckbox(
                                  //   viewModel: widget.viewModel,
                                  //   filterType: "Firma",
                                  //   choices: const [
                                  //     "Isbank",
                                  //     "Money",
                                  //     "Evidea",
                                  //   ],
                                  // ),
                                  // const ColumnDivider(verticalOffset: 5, horizontalOffset: 0),
                                  FilterMultipleCheckbox(
                                    viewModel: widget.viewModel,
                                    filterType: "Kategori",
                                    choices: const [
                                      'Giyim',
                                      'Elektronik',
                                      'Ev',
                                      'Finans',
                                      'Tatil',
                                      'Ulaşım',
                                      'Telekom',
                                      'Bebek',
                                      'Araç',
                                      'Kozmetik',
                                      'Market',
                                    ],
                                  ),
                                  const ColumnDivider(verticalOffset: 5, horizontalOffset: 0),
                                  FilterMultipleCheckbox(
                                    viewModel: widget.viewModel,
                                    filterType: "Tip",
                                    choices: const [
                                      'Özel günler',
                                      'İndirim',
                                      'Kupon',
                                      'Çekiliş',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CustomFilledButton(
                backgroundColor: ButtonColors.PRIMARY_COLOR,
                text: "Sonuçlar",
                textStyle: const TextStyle(
                  color: TextColors.BUTTON_TEXT_COLOR,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onTap: () {
                  widget.viewModel.filterOffers();
                  widget.viewModel.sortResultOffers(
                      widget.viewModel.isSelected[0] ||
                          widget.viewModel.isSelected[1],
                      widget.viewModel.isSelected[0] ||
                          widget.viewModel.isSelected[2]);
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SortByWidget extends StatefulWidget {
  List<bool> isSelected;
  SortByWidget({
    Key? key,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<SortByWidget> createState() => _SortByWidgetState();
}

class _SortByWidgetState extends BaseState<SortByWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sıralama",
          style: TextStyle(
            color: TextColors.PRIMARY_COLOR,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Center(
          child: ToggleButtons(
            borderRadius: AppBorderRadius.SMALL,
            fillColor: ButtonColors.PRIMARY_COLOR,
            isSelected: widget.isSelected,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < widget.isSelected.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    widget.isSelected[buttonIndex] = true;
                  } else {
                    widget.isSelected[buttonIndex] = false;
                  }
                }
              });
            },
            children: <Widget>[
              buildToggle("Tarih", true),
              buildToggle("Tarih", false),
              buildToggle("Firma", true),
              buildToggle("Firma", false),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox buildToggle(String text, bool isDesc) {
    return SizedBox(
      width: dyanmicWidthDevice(0.22),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: TextStyles.SMALL_B,
            ),
            Icon(
              isDesc
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: AssetColors.SORT_COLOR,
            )
          ],
        ),
      ),
    );
  }
}
