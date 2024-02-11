import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/product/widget/custom_search_bar.dart';
import 'package:mobile_app/product/widget/list_tiles/site_list_tile.dart';
import 'package:mobile_app/services/flask.dart';

class OfferPreferencesView extends StatefulWidget {
  const OfferPreferencesView({super.key});

  @override
  State<OfferPreferencesView> createState() => _OfferPreferencesViewState();
}

class _OfferPreferencesViewState extends BaseState<OfferPreferencesView> {
  final FlaskService flaskService = FlaskService();

  final TextEditingController siteUrlController = TextEditingController();

  final urlCheck = RegExp(r"^https:\/\/www\..*\.(com|tr|org)$");

  String? errorText;
  bool isScraperRunning = false;

  final List<Map<String, String>> preferred = [
    {
      "site_name": "Isbank",
      "url": "https://www.isbank.com.tr",
      "last_scrape_date": "10.02.2024"
    },
    {
      "site_name": "Bellona",
      "url": "https://www.bellona.com.tr",
      "last_scrape_date": "11.02.2024"
    },
  ];

  final List<Map<String, String>> notPreferred = [
    {
      "site_name": "MediaMarkt",
      "url": "https://www.mediamarkt.com.tr",
      "last_scrape_date": "10.02.2024"
    },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 22,
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: AppPaddings.SMALL_H,
                          enabled: !isScraperRunning,
                          border: OutlineInputBorder(
                            borderRadius: AppBorderRadius.MEDIUM,
                            borderSide: const BorderSide(
                              color: BorderColors.SECONDARY_COLOR,
                              width: 2,
                            ),
                          ),
                          hintText: "https://www.examplesite.com",
                          hintStyle:
                              const TextStyle(color: TextColors.HINT_COLOR),
                          errorText: errorText,
                        ),
                        controller: siteUrlController,
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: isScraperRunning
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Ink(
                              decoration: ShapeDecoration(
                                color: AssetColors.SECONDARY_COLOR,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.MEDIUM,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.search_rounded),
                                color: Colors.white,
                                onPressed: () {
                                  final text = siteUrlController.value.text;
                                  setState(() {
                                    errorText = null;
                                    if (text.isEmpty) {
                                      errorText = "Bu alan boş bırakılamaz";
                                    } else if (!urlCheck.hasMatch(text)) {
                                      errorText =
                                          "Lütfen geçerli bir URL giriniz";
                                    }
                                  });
                                  if (urlCheck.hasMatch(text)) {
                                    setState(() {
                                      isScraperRunning = true;
                                    });
                                    flaskService
                                        .runScraper(siteUrlController.text)
                                        .then((_) {
                                      setState(() {
                                        isScraperRunning = false;
                                        siteUrlController.clear();
                                      });
                                    });
                                  }
                                },
                              ),
                            ),
                    ),
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
                            siteName: preferred[index]["site_name"]!,
                            url: preferred[index]["url"]!,
                            isPreferred: true,
                          );
                        },
                      ),
                      ListView.builder(
                        itemCount: notPreferred.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SiteListTile(
                            id: index,
                            siteName: notPreferred[index]["site_name"]!,
                            url: notPreferred[index]["url"]!,
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
      height: dynamicHeightDevice(0.07),
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
