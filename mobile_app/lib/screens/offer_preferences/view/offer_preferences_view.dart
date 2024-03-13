import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/core/base/view/base_view.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/models/site_model.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/product/widget/custom_search_bar.dart';
import 'package:mobile_app/product/widget/list_tiles/site_list_tile.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';
import 'package:mobile_app/screens/offer_preferences/viewmodel/offer_preferences_viewmodel.dart';
import 'package:mobile_app/services/flask.dart';

class OfferPreferencesView extends StatefulWidget {
  final OfferViewModel offerViewModel;
  const OfferPreferencesView({
    super.key,
    required this.offerViewModel,
  });

  @override
  State<OfferPreferencesView> createState() => _OfferPreferencesViewState();
}

class _OfferPreferencesViewState extends BaseState<OfferPreferencesView> {
  late OfferPreferencesViewModel viewModel;
  final FlaskService flaskService = FlaskService();

  final TextEditingController siteUrlController = TextEditingController();

  String? errorText;
  bool isScraperRunning = false;

  @override
  void initState() {
    viewModel = OfferPreferencesViewModel();
    viewModel.setCurrentUser().then((value) {
      viewModel.getAllSites().then((value) {
        viewModel.splitPreferencesSites();
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<OfferPreferencesViewModel>(
      viewModel: viewModel,
      onModelReady: (model) {
        model.setContext(context);
        viewModel = model;
      },
      onPageBuilder: (context, value) => buildPage(context),
    );
  }

  Column buildPage(BuildContext context) {
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
                                    } else if (!viewModel.urlCheck
                                        .hasMatch(text)) {
                                      errorText =
                                          "Lütfen geçerli bir URL giriniz";
                                    } else if (viewModel.siteExist(text)) {
                                      errorText =
                                          "Girilen site aşağıda yer almaktadır";
                                    }
                                  });
                                  if (viewModel.urlCheck.hasMatch(text) &&
                                      !viewModel.siteExist(text)) {
                                    setState(() {
                                      isScraperRunning = true;
                                    });
                                    flaskService.runScraper(text).then((_) {
                                      setState(() {
                                        isScraperRunning = false;
                                        siteUrlController.clear();
                                        viewModel
                                            .changeNewSitePreference(text)
                                            .then((value) {
                                          viewModel.getAllSites().then((value) {
                                            viewModel.splitPreferencesSites();
                                          });
                                        });
                                        widget.offerViewModel
                                            .getAllOffers()
                                            .then((value) {
                                          widget.offerViewModel
                                              .updateResultOffers(widget
                                                  .offerViewModel.allOffers);
                                        });
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
                  child: Observer(
                    builder: (_) => TabBarView(
                      children: [
                        ListView.builder(
                          itemCount: viewModel.prefered.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot document =
                                viewModel.prefered[index];
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            SiteModel site =
                                SiteModel.fromJson(data, document.id);
                            return SiteListTile(
                              site: site,
                              isPrefered: true,
                              viewModel: viewModel,
                            );
                          },
                        ),
                        ListView.builder(
                          itemCount: viewModel.notPrefered.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot document =
                                viewModel.notPrefered[index];
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            SiteModel site =
                                SiteModel.fromJson(data, document.id);
                            return SiteListTile(
                              site: site,
                              isPrefered: false,
                              viewModel: viewModel,
                            );
                          },
                        ),
                      ],
                    ),
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
