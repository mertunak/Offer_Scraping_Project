import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../product/constants/utils/border_radius_constants.dart';
import '../../../product/constants/utils/color_constants.dart';
import '../../../product/constants/utils/padding_constants.dart';

// ignore: must_be_immutable
class OfferDetailView extends BaseStatelessWidget {
  late Uri _url;
  final OfferModel offer;
  OfferDetailView(this.offer, {super.key}) {
    _url = Uri.parse(offer.link);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Text(
            "${offer.site} Kampanya",
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          height: dynamicHeightDevice(context, 0.1),
          child: buildLinkButton(context),
        ),
        body: Padding(
          padding: AppPaddings.MEDIUM_H + AppPaddings.SMALL_V,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(offer.img),
                    Padding(
                      padding: AppPaddings.SMALL_V + AppPaddings.SMALL_H,
                      child: InkWell(
                        onTap: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                          ]);
                          showImageViewer(
                            context,
                            Image.network(offer.img).image,
                            swipeDismissible: false,
                            onViewerDismissed: () {
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                              ]);
                            },
                          );
                        },
                        child: const CircleAvatar(
                          backgroundColor: ButtonColors.PRIMARY_COLOR,
                          child: Icon(
                            Icons.touch_app_rounded,
                            color: AssetColors.PRIMARY_COLOR,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: dynamicHeightDevice(context, 0.01),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text:
                          "${offer.startDate} - ${offer.endDate}",
                      style: const TextStyle(
                        color: TextColors.PRIMARY_COLOR,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: " tarihleri arasında geçerli.",
                          style: TextStyle(
                            color: TextColors.PRIMARY_COLOR,
                            fontSize: 16,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: dynamicHeightDevice(context, 0.03),
                ),
                Text(
                  offer.header,
                  style: const TextStyle(
                    color: TextColors.PRIMARY_COLOR,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: dynamicHeightDevice(context, 0.02),
                ),
                Text(
                  offer.description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    color: TextColors.PRIMARY_COLOR,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell buildLinkButton(BuildContext context) {
    return InkWell(
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      onTap: _launchUrl,
      child: Container(
        decoration: BoxDecoration(
          color: ButtonColors.PRIMARY_COLOR,
          borderRadius: AppBorderRadius.LARGE,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Kampanyaya Git",
              style: TextStyle(
                color: TextColors.BUTTON_TEXT_COLOR,
                fontSize: dynamicHeightDevice(context, 0.028),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
