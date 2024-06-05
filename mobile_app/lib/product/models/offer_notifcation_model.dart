class OfferNotificationModel {
  late final String _id;
  //user id
  late final _userId;
  late final Map<String, int> _offerData; //offerId, notificationTime
  late final bool _isSent;
  OfferNotificationModel();

  OfferNotificationModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _userId = json['user_id'];
    _offerData = json['offer_data'];
    _isSent = json['is_sent'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = _id;
    data['user_id'] = _userId;
    data['offer_data'] = _offerData;
    data['is_sent'] = _isSent;
    return data;
  }

  String? get id => _id;
  bool get isSent => _isSent;
}
