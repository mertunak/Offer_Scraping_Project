import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/widget/cards/offer_card.dart';
import 'package:mobile_app/screens/fav_offers/viewmodel/fav_offers_viewmodel.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';

import '../../../core/base/view/base_view.dart';

class FavOffersView extends StatefulWidget {
  FavOffersView({super.key});

  @override
  State<FavOffersView> createState() => _FavOffersViewState();
}

class _FavOffersViewState extends State<FavOffersView> {
  late FavOffersViewModel viewModel;

  @override
  void initState() {
    viewModel = FavOffersViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<FavOffersViewModel>(
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
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Center();
            },
          );
        },
      );
    }
  }
}
