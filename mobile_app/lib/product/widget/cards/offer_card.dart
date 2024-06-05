import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/product/widget/alert/notification_setting_alert.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/screens/fav_offers/viewmodel/fav_offers_viewmodel.dart';
import 'package:mobile_app/screens/offer_detail/view/offer_detail_view.dart';
import '../../constants/utils/color_constants.dart';
import '../../models/offer_model.dart';
import 'package:share_plus/share_plus.dart';

class OfferCard extends StatefulWidget {
  final OfferModel offer;
  final FavOffersViewModel favOffersViewModel;
  final bool isHome;
  final bool isFav;
  OfferCard({
    super.key,
    required this.offer,
    required this.favOffersViewModel,
    required this.isHome,
    required this.isFav,
  });

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends BaseState<OfferCard> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.offer.site,
                style: const TextStyle(
                  color: TextColors.PRIMARY_COLOR,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 15,
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                      icon: Icon(Icons.share_rounded),
                      onPressed: () {
                        Share.share(
                            'Bu Kampanyaya Göz At!!!\n\n${widget.offer.header}\n${widget.offer.link}');
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  widget.isHome
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 15,
                          child: IconButton(
                            highlightColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            iconSize: 30,
                            icon: isFav
                                ? const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.red,
                                  )
                                : widget.isFav
                                    ? const Icon(
                                        Icons.favorite_rounded,
                                        color: Colors.red,
                                      )
                                    : Icon(
                                        Icons.favorite_border_rounded,
                                      ),
                            onPressed: () {
                              print("Fav offer id: " + widget.offer.id);
                              UserManager.instance
                                  .changeFavorite(widget.isFav, widget.offer.id)
                                  .then((value) {
                                widget.favOffersViewModel.getFavOffers();
                              });
                              setState(() {
                                isFav = !isFav;
                              });
                            },
                          ),
                        )
                      : Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 15,
                              child: IconButton(
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                iconSize: 30,
                                icon: Icon(Icons.edit_notifications),
                                onPressed: () {
                                  print("Uyarı: ${widget.offer.id}");
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return NotificationSettingAlert(
                                          offerModel: widget.offer,
                                          width: dyanmicWidthDevice(0.8),
                                          height: dynamicHeightDevice(0.5),
                                        );
                                      });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 15,
                              child: IconButton(
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                iconSize: 30,
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  UserManager.instance
                                      .changeFavorite(!isFav, widget.offer.id)
                                      .then((value) {
                                    widget.favOffersViewModel.getFavOffers();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ],
          ),
          const ColumnDivider(
            verticalOffset: 8,
            horizontalOffset: 0,
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OfferDetailView(widget.offer),
                ),
              );
            },
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            highlightColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: AppBorderRadius.MEDIUM,
                    child: Image.network(
                      widget.offer.img,
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.offer.header,
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
                  widget.offer.description,
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
                widget.offer.startDate.isEmpty
                    ? widget.offer.endDate.isEmpty
                        ? const SizedBox()
                        : Row(
                            children: [
                              const Text(
                                "Bitiş Tarihi: ",
                                style: TextStyle(
                                  color: TextColors.HIGHLIGHTED_COLOR,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.offer.endDate,
                                style: const TextStyle(
                                  color: TextColors.PRIMARY_COLOR,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                    : widget.offer.endDate.isEmpty
                        ? Row(
                            children: [
                              const Text(
                                "Başlangıç Tarihi",
                                style: TextStyle(
                                  color: TextColors.HIGHLIGHTED_COLOR,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.offer.startDate,
                                style: const TextStyle(
                                  color: TextColors.PRIMARY_COLOR,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Row(
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
                                      widget.offer.startDate,
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
                                      widget.offer.endDate,
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
          ),
        ],
      ),
    );
  }
}
