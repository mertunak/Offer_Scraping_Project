import 'package:flutter/material.dart';

class ColumnDivider extends StatelessWidget {
  final double verticalOffset;
  final double horizontalOffset;
  const ColumnDivider(
      {super.key,
      required this.verticalOffset,
      required this.horizontalOffset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalOffset,
        vertical: verticalOffset,
      ),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(15, 0, 0, 0))),
      ),
    );
  }
}
