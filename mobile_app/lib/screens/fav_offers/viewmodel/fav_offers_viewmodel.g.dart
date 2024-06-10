// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fav_offers_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FavOffersViewModel on _FavOffersVieModelBase, Store {
  late final _$favOffersAtom =
      Atom(name: '_FavOffersVieModelBase.favOffers', context: context);

  @override
  ObservableList<DocumentSnapshot<Object?>> get favOffers {
    _$favOffersAtom.reportRead();
    return super.favOffers;
  }

  @override
  set favOffers(ObservableList<DocumentSnapshot<Object?>> value) {
    _$favOffersAtom.reportWrite(value, super.favOffers, () {
      super.favOffers = value;
    });
  }

  late final _$getAllOffersAsyncAction =
      AsyncAction('_FavOffersVieModelBase.getAllOffers', context: context);

  @override
  Future<void> getAllOffers() {
    return _$getAllOffersAsyncAction.run(() => super.getAllOffers());
  }

  @override
  String toString() {
    return '''
favOffers: ${favOffers}
    ''';
  }
}
