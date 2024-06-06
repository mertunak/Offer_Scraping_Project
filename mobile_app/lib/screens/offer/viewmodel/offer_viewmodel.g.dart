// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OfferViewModel on _OfferViewModelBase, Store {
  late final _$resultOffersAtom =
      Atom(name: '_OfferViewModelBase.resultOffers', context: context);

  @override
  ObservableList<DocumentSnapshot<Object?>> get resultOffers {
    _$resultOffersAtom.reportRead();
    return super.resultOffers;
  }

  @override
  set resultOffers(ObservableList<DocumentSnapshot<Object?>> value) {
    _$resultOffersAtom.reportWrite(value, super.resultOffers, () {
      super.resultOffers = value;
    });
  }

  late final _$favSiteNamesAtom =
      Atom(name: '_OfferViewModelBase.favSiteNames', context: context);

  @override
  ObservableList<String> get favSiteNames {
    _$favSiteNamesAtom.reportRead();
    return super.favSiteNames;
  }

  @override
  set favSiteNames(ObservableList<String> value) {
    _$favSiteNamesAtom.reportWrite(value, super.favSiteNames, () {
      super.favSiteNames = value;
    });
  }

  late final _$resultCountAtom =
      Atom(name: '_OfferViewModelBase.resultCount', context: context);

  @override
  int get resultCount {
    _$resultCountAtom.reportRead();
    return super.resultCount;
  }

  @override
  set resultCount(int value) {
    _$resultCountAtom.reportWrite(value, super.resultCount, () {
      super.resultCount = value;
    });
  }

  late final _$choiceFiltersAtom =
      Atom(name: '_OfferViewModelBase.choiceFilters', context: context);

  @override
  Map<String, Map<String, bool>> get choiceFilters {
    _$choiceFiltersAtom.reportRead();
    return super.choiceFilters;
  }

  @override
  set choiceFilters(Map<String, Map<String, bool>> value) {
    _$choiceFiltersAtom.reportWrite(value, super.choiceFilters, () {
      super.choiceFilters = value;
    });
  }

  late final _$getAllOffersAsyncAction =
      AsyncAction('_OfferViewModelBase.getAllOffers', context: context);

  @override
  Future<void> getAllOffers() {
    return _$getAllOffersAsyncAction.run(() => super.getAllOffers());
  }

  late final _$getFavSiteNamesAsyncAction =
      AsyncAction('_OfferViewModelBase.getFavSiteNames', context: context);

  @override
  Future<void> getFavSiteNames(List<String> siteIds) {
    return _$getFavSiteNamesAsyncAction
        .run(() => super.getFavSiteNames(siteIds));
  }

  late final _$filterOffersAsyncAction =
      AsyncAction('_OfferViewModelBase.filterOffers', context: context);

  @override
  Future<void> filterOffers() {
    return _$filterOffersAsyncAction.run(() => super.filterOffers());
  }

  late final _$_OfferViewModelBaseActionController =
      ActionController(name: '_OfferViewModelBase', context: context);

  @override
  void initOfferLists() {
    final _$actionInfo = _$_OfferViewModelBaseActionController.startAction(
        name: '_OfferViewModelBase.initOfferLists');
    try {
      return super.initOfferLists();
    } finally {
      _$_OfferViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateResultOffers(List<DocumentSnapshot<Object?>> resultList) {
    final _$actionInfo = _$_OfferViewModelBaseActionController.startAction(
        name: '_OfferViewModelBase.updateResultOffers');
    try {
      return super.updateResultOffers(resultList);
    } finally {
      _$_OfferViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sortResultOffers(bool isDate, bool isDesc) {
    final _$actionInfo = _$_OfferViewModelBaseActionController.startAction(
        name: '_OfferViewModelBase.sortResultOffers');
    try {
      return super.sortResultOffers(isDate, isDesc);
    } finally {
      _$_OfferViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addResultOffers(DocumentSnapshot<Object?> offerSnapshot) {
    final _$actionInfo = _$_OfferViewModelBaseActionController.startAction(
        name: '_OfferViewModelBase.addResultOffers');
    try {
      return super.addResultOffers(offerSnapshot);
    } finally {
      _$_OfferViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearResultOffers() {
    final _$actionInfo = _$_OfferViewModelBaseActionController.startAction(
        name: '_OfferViewModelBase.clearResultOffers');
    try {
      return super.clearResultOffers();
    } finally {
      _$_OfferViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeCheckboxFilter(
      String filterKey, String choiceKey, bool isSelected) {
    final _$actionInfo = _$_OfferViewModelBaseActionController.startAction(
        name: '_OfferViewModelBase.changeCheckboxFilter');
    try {
      return super.changeCheckboxFilter(filterKey, choiceKey, isSelected);
    } finally {
      _$_OfferViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
resultOffers: ${resultOffers},
favSiteNames: ${favSiteNames},
resultCount: ${resultCount},
choiceFilters: ${choiceFilters}
    ''';
  }
}
