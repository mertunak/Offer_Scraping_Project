// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'color_constants.dart';

class TextStyles {
  static const SMALL = TextStyle(
    color: TextColors.PRIMARY_COLOR,
    fontSize: 16,
  );
  static const SMALL_B = TextStyle(
      color: TextColors.PRIMARY_COLOR,
      fontSize: 16,
      fontWeight: FontWeight.bold);
  static const MEDIUM = TextStyle(
    color: TextColors.PRIMARY_COLOR,
    fontSize: 24,
  );
  static const MEDIUM_B = TextStyle(
      color: TextColors.PRIMARY_COLOR,
      fontSize: 24,
      fontWeight: FontWeight.bold);
  static const LARGE_B = TextStyle(
    color: TextColors.PRIMARY_COLOR,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  static const LARGE = TextStyle(
    color: TextColors.PRIMARY_COLOR,
    fontSize: 32,
  );
  static const HOME_HEADING = TextStyle(
    color: TextColors.SECONDARY_COLOR,
    fontSize: 30,
  );
  static const TEXT_BUTTON = TextStyle(
    color: TextColors.SECONDARY_COLOR,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const BUTTON = TextStyle(
    color: TextColors.BUTTON_TEXT_COLOR,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
