import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobx/mobx.dart';

import '../../../services/firestore.dart';
part 'offer_viewmodel.g.dart';

class OfferViewModel = _OfferViewModelBase with _$OfferViewModel;

abstract class _OfferViewModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();

  List<DocumentSnapshot> allCampaigns = [];
  List<DocumentSnapshot> filterResults = [];

  Map<String, bool> brandMap = {
    'filterActive': false,
    'apple': false,
    'samsung': false,
    'huawei': false,
    'xiomi': false,
    'lenovo': false,
    'casper': false,
  };

  Map<String, bool> sizeMap = {
    'filterActive': false,
    '10_9 inç': false,
    '11 inç': false,
    '12_9 inç': false,
    '8 inç': false,
    '11_7 inç': false,
  };

  Map<String, bool> siteMap = {
    'filterActive': false,
    'İş Bankası': false,
    'Bellona': false,
    'Migros': false,
    'OBilet': false,
    'THY': false,
    'Koton': false,
    'Vatan': false,
    'Mediamarkt': false,
    'Teknosa': false,
  };

  @observable
  List<DocumentSnapshot> resultCampaigns = [];

  @observable
  int resultCount = 0;

  @observable
  Map<String, Map<String, bool>> choiceFilters = {};

  @observable
  List<String> priceFilter = [];

  _OfferViewModelBase() {
    init();
  }

  @override
  void init() {
    choiceFilters = {
      'marka': brandMap,
      'boyut': sizeMap,
      'site': siteMap,
    };
  }

  Future<void> getAllCampaigns() async {
    final data = await firestoreService.getCampaigns();
    allCampaigns = data.docs;
  }

  @action
  void addResultCampaigns(DocumentSnapshot campaignSnapshot) {
    resultCampaigns.add(campaignSnapshot);
    resultCount = resultCampaigns.length;
  }

  @action
  void initCampaignLists() {
    updateResultCampaigns(allCampaigns);
    filterResults = List.from(allCampaigns);
  }

  @action
  void clearResultCampaigns() {
    resultCampaigns.clear();
    resultCount = resultCampaigns.length;
  }

  @action
  void updateResultCampaigns(List<DocumentSnapshot> resultList) {
    resultCampaigns = List.from(resultList);
    resultCount = resultCampaigns.length;
  }

  @action
  void changeCheckboxFilter(
      String filterKey, String choiceKey, bool isSelected) {
    filterKey = filterKey.toLowerCase();
    choiceKey = choiceKey.toLowerCase().replaceAll(".", "_");
    Map<String, bool> filterMap = choiceFilters[filterKey]!;
    filterMap[choiceKey] = isSelected;
    filterMap["filterActive"] = false;
    for (var option in filterMap.values) {
      if (option == true) {
        filterMap["filterActive"] = true;
        break;
      }
    }
  }

  @action
  Future<void> filterCampaigns(
    TextEditingController leastPriceController,
    TextEditingController mostPriceController,
  ) async {
    List<String> campaignIds = [];
    List<String> tmpIds = [];
    List<String> filterCampaignIds = [];
    Map<String, bool> filterMap;
    for (DocumentSnapshot campaignSnapshot in allCampaigns) {
      campaignIds.add(campaignSnapshot.id);
    }
    for (var choiceFilterKey in choiceFilters.keys) {
      filterMap = choiceFilters[choiceFilterKey]!;
      if (filterMap["filterActive"] == true) {
        tmpIds = [];
        for (var filterMapKey in filterMap.keys) {
          if (filterMap[filterMapKey] == true) {
            if (filterMapKey.compareTo("filterActive") != 0) {
              // filterCampaignIds = await firestoreService.getFilterCampaignIds(filterMapKey);
              tmpIds = List.from(tmpIds)..addAll(filterCampaignIds);
            }
          }
        }
        campaignIds.removeWhere((element) => !tmpIds.contains(element));
      }
    }

    filterResults = List.of(allCampaigns);
    filterResults.removeWhere((element) => !campaignIds.contains(element.id));
    if (leastPriceController.text != "") {
      double leastPrice = double.parse(leastPriceController.text);
      filterResults.removeWhere(
          (element) => double.parse(element["product_price"]) < leastPrice);
    }
    if (mostPriceController.text != "") {
      double mostPrice = double.parse(mostPriceController.text);
      filterResults.removeWhere(
          (element) => double.parse(element["product_price"]) > mostPrice);
    }
    updateResultCampaigns(filterResults);
  }

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }
}
