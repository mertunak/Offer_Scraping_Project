import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import '../constants/utils/color_constants.dart';
import '../models/offer_model.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  const OfferCard({
    super.key,
    required this.offer,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
            NavigationConstants.OFFER_DETAIL_VIEW,
            arguments: offer);
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
                offer.site,
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
                  offer.img,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Text(
                  offer.header,
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
                  offer.description,
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
                            offer.startDate,
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
                            offer.endDate,
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
