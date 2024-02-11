import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';

class SiteListTile extends StatelessWidget {
  final int id;
  final String siteName;
  final String url;
  final bool isPreferred;
  const SiteListTile({
    super.key,
    required this.siteName,
    required this.id,
    required this.isPreferred, required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(siteName),
        subtitle: Text(url),
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
