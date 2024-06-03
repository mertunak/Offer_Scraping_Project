import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/widget/filter_component/custom_checkbox.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';
import '../../constants/utils/color_constants.dart';

class FilterMultipleCheckbox extends BaseStatelessWidget {
  final OfferViewModel viewModel;
  final String filterType;
  final List<String> choices;
  const FilterMultipleCheckbox(
      {required this.viewModel,
      required this.filterType,
      required this.choices,
      super.key});

  @override
  Widget build(BuildContext context) {
    return choices.isEmpty ? Center() : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filterType,
          style: const TextStyle(
            color: TextColors.PRIMARY_COLOR,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(
          height: dynamicHeightDevice(context, 0.15),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: dynamicWidthDevice(context, 0.9),
            ),
            itemCount: choices.length,
            itemBuilder: (BuildContext context, int index) {
              return CustomCheckbox(
                choice: choices[index],
                viewModel: viewModel,
                filterType: filterType,
              );
            },
          ),
        ),
      ],
    );
  }
}
