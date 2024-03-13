import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/models/site_model.dart';
import 'package:mobile_app/screens/offer_preferences/viewmodel/offer_preferences_viewmodel.dart';

class SiteListTile extends StatelessWidget {
  final SiteModel site;
  final bool isPrefered;
  final OfferPreferencesViewModel viewModel;
  const SiteListTile({
    super.key,
    required this.site,
    required this.isPrefered,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(site.siteName!),
        subtitle: Text(site.url!),
        trailing: IconButton(
          onPressed: () {
            viewModel.changePreference(isPrefered, site.id!);
          },
          icon: Icon(
            isPrefered == true
                ? Icons.delete_outline_rounded
                : Icons.add_rounded,
            color: AssetColors.SECONDARY_COLOR,
            size: 30,
          ),
        ),
      ),
    );
  }
}
