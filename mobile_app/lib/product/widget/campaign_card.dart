import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import '../constants/utils/color_constants.dart';
import '../models/campaign_model.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  const CampaignCard({
    super.key,
    required this.campaign,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
            NavigationConstants.CAMPAIGN_DETAIL_VIEW,
            arguments: campaign);
      },
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: AppPaddings.MEDIUM_V + AppPaddings.MEDIUM_H,
        decoration: BoxDecoration(
          color: const Color.fromARGB(15, 133, 200, 137),
          borderRadius: AppBorderRadius.MEDIUM,
          border: Border.all(
            color: const Color.fromARGB(20, 133, 200, 137),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                campaign.site,
                style: const TextStyle(
                  color: TextColors.PRIMARY_COLOR,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const ColumnDivider(
              verticalOffset: 8,
              horizontalOffset: 0,
            ),
            ClipRRect(
              borderRadius: AppBorderRadius.MEDIUM,
              child: Image.network(
                campaign.img,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Text(
                  campaign.header,
                  style: const TextStyle(
                    color: TextColors.PRIMARY_COLOR,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  campaign.description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    color: TextColors.PRIMARY_COLOR,
                    fontSize: 12,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Başlangıç Tarihi",
                            style: TextStyle(
                              color: TextColors.HIGHLIGHTED_COLOR,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            campaign.startDate,
                            style: const TextStyle(
                              color: TextColors.PRIMARY_COLOR,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Bitiş Tarihi",
                            style: TextStyle(
                              color: TextColors.HIGHLIGHTED_COLOR,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            campaign.endDate,
                            style: const TextStyle(
                              color: TextColors.PRIMARY_COLOR,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
