import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/widget/cards/offer_card.dart';
import 'package:mobile_app/product/widget/custom_search_bar.dart';
import 'package:mobile_app/screens/fav_offers/viewmodel/fav_offers_viewmodel.dart';

import '../../../core/base/view/base_view.dart';

class FavOffersView extends StatefulWidget {
  final FavOffersViewModel viewModel;
  const FavOffersView({
    super.key,
    required this.viewModel,
  });

  @override
  State<FavOffersView> createState() => _FavOffersViewState();
}

class _FavOffersViewState extends State<FavOffersView> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    widget.viewModel.getFavOffers();
    super.initState();
  }

  // _searchOffers() {
  //   if (_searchController.text != "") {
  //     widget.viewModel.clearResultOffers();
  //     for (var offerSnapshot in widget.viewModel.favOffers) {
  //       var name = offerSnapshot["title"].toString().toLowerCase();
  //       name += " ${offerSnapshot["description"].toString().toLowerCase()}";
  //       if (name.contains(_searchController.text.toLowerCase())) {
  //         widget.viewModel.addResultOffers(offerSnapshot);
  //       }
  //     }
  //   } else {
  //     widget.viewModel.updateResultOffers(widget.viewModel.favOffers);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<FavOffersViewModel>(
      viewModel: widget.viewModel,
      onModelReady: (model) {
        model.setContext(context);
      },
      onPageBuilder: (context, value) => buildPage(context),
    );
  }

  buildPage(BuildContext context) {
    {
      return Observer(
        builder: (_) {
          return Column(
            children: [
              CustomSearchBar(
                searchController: _searchController,
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.viewModel.favOffers.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document =
                        widget.viewModel.favOffers[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    OfferModel offer = OfferModel.fromJson(data, document.id);
                    return OfferCard(
                      offer: offer,
                      favOffersViewModel: widget.viewModel,
                      isHome: false,
                    );
                  },
                ),
              )
            ],
          );
        },
      );
    }
  }
}
