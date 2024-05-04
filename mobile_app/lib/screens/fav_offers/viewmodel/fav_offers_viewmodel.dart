import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobx/mobx.dart';
part 'fav_offers_viewmodel.g.dart';

class FavOffersViewModel = _FavOffersVieModelBase with _$FavOffersViewModel;

abstract class _FavOffersVieModelBase extends BaseViewModel with Store {
  @override
  void init() {}

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }
}
