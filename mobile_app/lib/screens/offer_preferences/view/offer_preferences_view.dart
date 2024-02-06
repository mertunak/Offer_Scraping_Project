import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/product/widget/custom_search_bar.dart';
import 'package:mobile_app/product/widget/list_tiles/site_list_tile.dart';

class OfferPreferencesView extends BaseStatelessWidget {
  OfferPreferencesView({super.key});
  final List<String> preferred = [
    "İş Bankası",
    "Bellona",
  ];
  final List<String> notPreferred = [
    "MediaMarkt",
    "Migros",
    "Vatan",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 12,
          child: Container(
            padding: AppPaddings.MEDIUM_V + AppPaddings.MEDIUM_H,
            decoration: BoxDecoration(
              color: const Color.fromARGB(15, 133, 200, 137),
              borderRadius: AppBorderRadius.MEDIUM,
              border: Border.all(
                color: const Color.fromARGB(20, 133, 200, 137),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Aradığın firmayı bulamıyorsan aşağıda yer alan alana site URL'ini girmeyi dene :)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      flex: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppBorderRadius.MEDIUM,
                          border: Border.all(
                            color: BorderColors.SECONDARY_COLOR,
                            width: 2,
                          ),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            contentPadding: AppPaddings.SMALL_H,
                            border: InputBorder.none,
                            hintText: "https://www.examplesite.com",
                            hintStyle: TextStyle(color: TextColors.HINT_COLOR),
                          ),
                          controller: TextEditingController(),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: AssetColors.SECONDARY_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.MEDIUM,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search_rounded),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const Spacer(),
        const ColumnDivider(verticalOffset: 0, horizontalOffset: 0),
        const Spacer(),
        Expanded(
          flex: 36,
          child: DefaultTabController(
            length: 2,
            animationDuration: const Duration(milliseconds: 500),
            initialIndex: 0,
            child: Column(
              children: [
                TabBar(
                  overlayColor:
                      const MaterialStatePropertyAll(Colors.transparent),
                  dividerColor: Colors.transparent,
                  labelColor: TextColors.BUTTON_TEXT_COLOR,
                  unselectedLabelColor: TextColors.PRIMARY_COLOR,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: ButtonColors.PRIMARY_COLOR,
                    borderRadius: AppBorderRadius.LARGE,
                  ),
                  tabs: [
                    buildTab(context, "Takip Edilen Firmalar"),
                    buildTab(context, "Takip Edilebilir Firmalar"),
                  ],
                ),
                const Spacer(),
                CustomSearchBar(searchController: TextEditingController()),
                const Spacer(),
                Expanded(
                  flex: 24,
                  child: TabBarView(
                    children: [
                      ListView.builder(
                        itemCount: preferred.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SiteListTile(
                            id: index,
                            title: preferred[index],
                            isPreferred: true,
                          );
                        },
                      ),
                      ListView.builder(
                        itemCount: notPreferred.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SiteListTile(
                            id: index,
                            title: notPreferred[index],
                            isPreferred: false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Tab buildTab(BuildContext context, String label) {
    return Tab(
      height: dynamicHeightDevice(context, 0.07),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
