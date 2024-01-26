// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeViewModel on _HomeViewModelBase, Store {
  late final _$resultCampaignsAtom =
      Atom(name: '_HomeViewModelBase.resultCampaigns', context: context);

  @override
  List<DocumentSnapshot<Object?>> get resultCampaigns {
    _$resultCampaignsAtom.reportRead();
    return super.resultCampaigns;
  }

  @override
  set resultCampaigns(List<DocumentSnapshot<Object?>> value) {
    _$resultCampaignsAtom.reportWrite(value, super.resultCampaigns, () {
      super.resultCampaigns = value;
    });
  }

  late final _$resultCountAtom =
      Atom(name: '_HomeViewModelBase.resultCount', context: context);

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
      Atom(name: '_HomeViewModelBase.choiceFilters', context: context);

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

  late final _$priceFilterAtom =
      Atom(name: '_HomeViewModelBase.priceFilter', context: context);

  @override
  List<String> get priceFilter {
    _$priceFilterAtom.reportRead();
    return super.priceFilter;
  }

  @override
  set priceFilter(List<String> value) {
    _$priceFilterAtom.reportWrite(value, super.priceFilter, () {
      super.priceFilter = value;
    });
  }

  late final _$filterCampaignsAsyncAction =
      AsyncAction('_HomeViewModelBase.filterCampaigns', context: context);

  @override
  Future<void> filterCampaigns(TextEditingController leastPriceController,
      TextEditingController mostPriceController) {
    return _$filterCampaignsAsyncAction.run(
        () => super.filterCampaigns(leastPriceController, mostPriceController));
  }

  late final _$_HomeViewModelBaseActionController =
      ActionController(name: '_HomeViewModelBase', context: context);

  @override
  void addResultCampaigns(DocumentSnapshot<Object?> campaignSnapshot) {
    final _$actionInfo = _$_HomeViewModelBaseActionController.startAction(
        name: '_HomeViewModelBase.addResultCampaigns');
    try {
      return super.addResultCampaigns(campaignSnapshot);
    } finally {
      _$_HomeViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initCampaignLists() {
    final _$actionInfo = _$_HomeViewModelBaseActionController.startAction(
        name: '_HomeViewModelBase.initCampaignLists');
    try {
      return super.initCampaignLists();
    } finally {
      _$_HomeViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearResultCampaigns() {
    final _$actionInfo = _$_HomeViewModelBaseActionController.startAction(
        name: '_HomeViewModelBase.clearResultCampaigns');
    try {
      return super.clearResultCampaigns();
    } finally {
      _$_HomeViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateResultCampaigns(List<DocumentSnapshot<Object?>> resultList) {
    final _$actionInfo = _$_HomeViewModelBaseActionController.startAction(
        name: '_HomeViewModelBase.updateResultCampaigns');
    try {
      return super.updateResultCampaigns(resultList);
    } finally {
      _$_HomeViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeCheckboxFilter(
      String filterKey, String choiceKey, bool isSelected) {
    final _$actionInfo = _$_HomeViewModelBaseActionController.startAction(
        name: '_HomeViewModelBase.changeCheckboxFilter');
    try {
      return super.changeCheckboxFilter(filterKey, choiceKey, isSelected);
    } finally {
      _$_HomeViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
resultCampaigns: ${resultCampaigns},
resultCount: ${resultCount},
choiceFilters: ${choiceFilters},
priceFilter: ${priceFilter}
    ''';
  }
}
