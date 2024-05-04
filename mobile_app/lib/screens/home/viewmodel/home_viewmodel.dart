import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/screens/fav_offers/viewmodel/fav_offers_viewmodel.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';
import 'package:mobx/mobx.dart';
part 'home_viewmodel.g.dart';

class HomeViewModel = _HomeViewModelBase with _$HomeViewModel;

abstract class _HomeViewModelBase extends BaseViewModel with Store {
  
  OfferViewModel offerviewModel = OfferViewModel();
  FavOffersViewModel favOffersViewModel  = FavOffersViewModel();

  @override
  void init() {
  }

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }
}