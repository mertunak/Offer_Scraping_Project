// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_preferences_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OfferPreferencesViewModel on _OfferPreferencesViewModelBase, Store {
  late final _$preferedAtom =
      Atom(name: '_OfferPreferencesViewModelBase.prefered', context: context);

  @override
  ObservableList<DocumentSnapshot<Object?>> get prefered {
    _$preferedAtom.reportRead();
    return super.prefered;
  }

  @override
  set prefered(ObservableList<DocumentSnapshot<Object?>> value) {
    _$preferedAtom.reportWrite(value, super.prefered, () {
      super.prefered = value;
    });
  }

  late final _$notPreferedAtom = Atom(
      name: '_OfferPreferencesViewModelBase.notPrefered', context: context);

  @override
  ObservableList<DocumentSnapshot<Object?>> get notPrefered {
    _$notPreferedAtom.reportRead();
    return super.notPrefered;
  }

  @override
  set notPrefered(ObservableList<DocumentSnapshot<Object?>> value) {
    _$notPreferedAtom.reportWrite(value, super.notPrefered, () {
      super.notPrefered = value;
    });
  }

  late final _$_OfferPreferencesViewModelBaseActionController =
      ActionController(
          name: '_OfferPreferencesViewModelBase', context: context);

  @override
  void changePreference(bool isPrefered, SiteModel site) {
    final _$actionInfo = _$_OfferPreferencesViewModelBaseActionController
        .startAction(name: '_OfferPreferencesViewModelBase.changePreference');
    try {
      return super.changePreference(isPrefered, site);
    } finally {
      _$_OfferPreferencesViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
prefered: ${prefered},
notPrefered: ${notPrefered}
    ''';
  }
}
