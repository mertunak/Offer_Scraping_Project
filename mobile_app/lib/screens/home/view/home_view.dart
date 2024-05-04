import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/core/base/view/base_view.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/screens/fav_offers/view/fav_offers_view.dart';
import 'package:mobile_app/screens/home/viewmodel/home_viewmodel.dart';
import 'package:mobile_app/screens/offer/view/offer_view.dart';
import 'package:mobile_app/screens/offer_preferences/view/offer_preferences_view.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/notifications_service.dart';
import 'package:mobile_app/services/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> {
  int currentPageIndex = 0;
  late HomeViewModel viewModel;

  @override
  void initState() {
    PushNotifications.getDeviceToken();
    viewModel = HomeViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStatefulView<HomeViewModel>(
      viewModel: viewModel,
      onModelReady: (model) {
        model.setContext(context);
        viewModel = model;
      },
      onPageBuilder: (context, value) => buildPage(context),
    );
  }

  Scaffold buildPage(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          currentPageIndex == 0
              ? 'Kampanyalar'
              : currentPageIndex == 1
                  ? 'Tercihler'
                  : 'Favoriler',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context)
                  .pushNamed(NavigationConstants.PROFILE_VIEW);
            },
            icon: const Icon(
              Icons.person,
              color: AssetColors.SECONDARY_COLOR,
              size: 35,
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context)
                  .pushNamed(NavigationConstants.NOTIFICATIONS_VIEW);
            },
            icon: const Icon(
              Icons.notifications_rounded,
              color: AssetColors.SECONDARY_COLOR,
              size: 35,
            ),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          elevation: 0,
          backgroundColor: SurfaceColors.PRIMARY_COLOR,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          height: dynamicHeightDevice(0.07),
          selectedIndex: currentPageIndex,
          indicatorColor: Colors.transparent,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.campaign,
                size: 40,
              ),
              icon: Icon(
                Icons.campaign_outlined,
                size: 35,
              ),
              label: 'Kampanyalar',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.screen_search_desktop_rounded,
                size: 35,
              ),
              icon: Icon(
                Icons.screen_search_desktop_outlined,
                size: 30,
              ),
              label: 'Tercihler',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.favorite_rounded,
                size: 35,
              ),
              icon: Icon(
                Icons.favorite_border_rounded,
                size: 30,
              ),
              label: 'Favoriler',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
            padding: AppPaddings.MEDIUM_H,
            child: IndexedStack(
              index: currentPageIndex,
              children: [
                OfferView(
                  viewModel: viewModel.offerviewModel,
                  favOffersViewModel: viewModel.favOffersViewModel,
                ),
                OfferPreferencesView(
                  offerViewModel: viewModel.offerviewModel,
                ),
                FavOffersView(
                  viewModel: viewModel.favOffersViewModel,
                ),
              ],
            )),
      ),
    );
  }
}
