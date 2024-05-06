import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
// import 'package:mobile_app/product/constants/utils/padding_constants.dart';
// import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/widget/custom_search_bar.dart';
import 'package:mobile_app/product/widget/bottom_sheets/filter_bottom_sheet.dart';
import 'package:mobile_app/product/widget/cards/offer_card.dart';
import 'package:mobile_app/screens/fav_offers/viewmodel/fav_offers_viewmodel.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';
import 'package:mobile_app/services/firestore.dart';

import '../../../core/base/view/base_view.dart';

class OfferView extends StatefulWidget {
  final OfferViewModel viewModel;
  final FavOffersViewModel favOffersViewModel;
  const OfferView({
    super.key,
    required this.viewModel,
    required this.favOffersViewModel,
  });

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController leastPriceController = TextEditingController();
  final TextEditingController mostPriceController = TextEditingController();

  bool notificationsScheduled = false;
  _searchOffers() {
    if (_searchController.text != "") {
      widget.viewModel.clearResultOffers();
      for (var offerSnapshot in widget.viewModel.filterResults) {
        var name = offerSnapshot["title"].toString().toLowerCase();
        name += " ${offerSnapshot["description"].toString().toLowerCase()}";
        if (name.contains(_searchController.text.toLowerCase())) {
          widget.viewModel.addResultOffers(offerSnapshot);
        }
      }
    } else {
      widget.viewModel.updateResultOffers(widget.viewModel.filterResults);
    }
  }

  @override
  void initState() {
    //widget.viewModel.resetNotificationFlags();
    widget.viewModel.getAllOffers().then((value) {
      widget.viewModel.initOfferLists();
    });

    _searchController.addListener(_searchOffers);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _searchOffers();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<OfferViewModel>(
      viewModel: widget.viewModel,
      onModelReady: (model) {
        model.setContext(context);
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
                  setState(() {
                    print("aaaaa");
                    print(widget.viewModel.allOffers);
                    print(widget.viewModel.resultOffers);
                  });
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return FilterBottomSheet(
                        viewModel: widget.viewModel,
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
                    "${widget.viewModel.resultCount} sonuç gösteriliyor...",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: ListView.builder(
                    itemCount: widget.viewModel.resultOffers.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document =
                          widget.viewModel.resultOffers[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      OfferModel offer = OfferModel.fromJson(data);
                      offer.setId(document.id);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OfferCard(
                          offer: offer,
                          favOffersViewModel: widget.favOffersViewModel,
                          isHome: true,
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
