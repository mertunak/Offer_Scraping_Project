import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/widget/cards/offer_card.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';

import '../../../core/base/view/base_view.dart';

class FavOffersView extends StatefulWidget {
  FavOffersView({super.key});

  @override
  State<FavOffersView> createState() => _FavOffersViewState();
}

class _FavOffersViewState extends State<FavOffersView> {
  late OfferViewModel viewModel;

  @override
  void initState() {
    viewModel = OfferViewModel();
    viewModel.getAllOffers().then((value) => viewModel.initOfferLists());
    viewModel.updateResultOffers(viewModel.allOffers);
    super.initState();
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

  buildPage(BuildContext context) {
    {
      return Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: viewModel.resultOffers.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = viewModel.resultOffers[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              OfferModel offer = OfferModel.fromJson(data);
              offer.setId(document.id);
              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: OfferCard(
                  offer: offer,
                ),
              );
            },
          );
        },
      );
    }
  }
}
