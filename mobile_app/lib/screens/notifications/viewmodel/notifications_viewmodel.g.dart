// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotificationViewModel on _NotificationViewModelBase, Store {
  late final _$notificationsListAtom = Atom(
      name: '_NotificationViewModelBase.notificationsList', context: context);

  @override
  ObservableList<OfferNotificationModel> get notificationsList {
    _$notificationsListAtom.reportRead();
    return super.notificationsList;
  }

  @override
  set notificationsList(ObservableList<OfferNotificationModel> value) {
    _$notificationsListAtom.reportWrite(value, super.notificationsList, () {
      super.notificationsList = value;
    });
  }

  late final _$getNotificationsAsyncAction = AsyncAction(
      '_NotificationViewModelBase.getNotifications',
      context: context);

  @override
  Future<void> getNotifications() {
    return _$getNotificationsAsyncAction.run(() => super.getNotifications());
  }

  @override
  String toString() {
    return '''
notificationsList: ${notificationsList}
    ''';
  }
}
