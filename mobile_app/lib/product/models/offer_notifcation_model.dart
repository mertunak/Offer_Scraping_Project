class OfferNotificationModel {
  late final String _userId;
  late final Map<String, Map<String, dynamic>>
      _offerData; // offers structured for JSON

  OfferNotificationModel(this._userId, this._offerData);

  OfferNotificationModel.fromJson(Map<String, dynamic> json) {
    _userId = json['user_id'];
    _offerData = Map<String, Map<String, dynamic>>.from(json['offer_data']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user_id'] = _userId;
    data['offer_data'] = _offerData;
    return data;
  }

  String get userId => _userId;
  Map<String, Map<String, dynamic>> get offerData => _offerData;
}
