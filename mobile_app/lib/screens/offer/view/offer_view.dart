import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/models/campaign_model.dart';
import 'package:mobile_app/product/widget/custom_search_bar.dart';
import 'package:mobile_app/product/widget/filter_component/filter_bottom_sheet.dart';
import 'package:mobile_app/product/widget/campaign_card.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';
import 'package:mobile_app/services/firestore.dart';

import '../../../core/base/view/base_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController leastPriceController = TextEditingController();
  final TextEditingController mostPriceController = TextEditingController();
  late OfferViewModel viewModel;

  _searchCampaigns() {
    if (_searchController.text != "") {
      viewModel.clearResultCampaigns();
      for (var campaignSnapshot in viewModel.filterResults) {
        var name = campaignSnapshot["product_name"].toString().toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          viewModel.addResultCampaigns(campaignSnapshot);
        }
      }
    } else {
      viewModel.updateResultCampaigns(viewModel.filterResults);
    }
  }

  @override
  void initState() {
    viewModel = OfferViewModel();
    viewModel.getAllCampaigns().then((value) => viewModel.initCampaignLists());
    _searchController.addListener(_searchCampaigns);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _searchCampaigns();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<OfferViewModel>(
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
        // const Expanded(
        //   flex: 3,
        //   child: Center(
        //     child: Text(ScreenTexts.HOME_TEXT,
        //         textAlign: TextAlign.center, style: TextStyles.HOME_HEADING),
        //   ),
        // ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: CustomSearchBar(
                  searchController: _searchController,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return FilterBottomSheet(
                        viewModel: viewModel,
                        leastPriceController: leastPriceController,
                        mostPriceController: mostPriceController,
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.filter_list_rounded,
                  size: 30,
                  color: AssetColors.SECONDARY_COLOR,
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 15,
          child: Observer(builder: (_) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${viewModel.resultCount} sonuç gösteriliyor...",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: ListView.builder(
                    itemCount: viewModel.resultCampaigns.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document =
                          viewModel.resultCampaigns[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      CampaignModel campaign = CampaignModel.fromJson(data);
                      campaign.setId(document.id);
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: CampaignCard(
                          campaign: campaign,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        )
      ],
    );
  }
}
