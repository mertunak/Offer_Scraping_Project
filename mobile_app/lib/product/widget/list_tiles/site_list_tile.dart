import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';

class SiteListTile extends StatelessWidget {
  final int id;
  final String title;
  final bool isPreferred;
  const SiteListTile({
    super.key,
    required this.title,
    required this.id,
    required this.isPreferred,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: IconButton(
          onPressed: () {
            if (isPreferred) {
              print("delete");
            } else {
              print("add");
            }
          },
          icon: Icon(
            isPreferred == true ? Icons.delete_outline_rounded : Icons.add_rounded,
            color: AssetColors.SECONDARY_COLOR,
            size: 30,
          ),
        ),
      ),
    );
  }
}
