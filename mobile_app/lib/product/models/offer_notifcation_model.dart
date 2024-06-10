class OfferNotificationModel {
  late final String _id;
  late final String _offerID;
  late final String _body;
  late final String _title;
  late final String _scheduledDate;
  late final bool _isNotified;
  late final int _notificationTime;

  OfferNotificationModel({
    required String id,
    required String offerID,
    required String body,
    required String title,
    required String scheduledDate,
    required bool isNotified,
    required int notificationTime,
  })  : _id = id,
        _offerID = offerID,
        _body = body,
        _title = title,
        _scheduledDate = scheduledDate,
        _isNotified = isNotified,
        _notificationTime = notificationTime;

  OfferNotificationModel.fromJson(Map<String, dynamic> json, String id) {
    _id = id;
    _offerID = json['offerID'];
    _body = json['body'];
    _title = json['title'];
    _scheduledDate = json['scheduledDate'];
    _isNotified = json['isNotified'];
    _notificationTime = json['notificationTime'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['offerID'] = _offerID;
    data['body'] = _body;
    data['title'] = _title;
    data['scheduledDate'] = _scheduledDate;
    data['isNotified'] = _isNotified;
    data['notificationTime'] = _notificationTime;
    return data;
  }

  String get id => _id;
  String get offerID => _offerID;
  String get body => _body;
  String get title => _title;
  String get scheduledDate => _scheduledDate;
  bool get isNotified => _isNotified;
  int get notificationTime => _notificationTime;

  set notificationTime(int value) {
    _notificationTime = value;
  }
}
