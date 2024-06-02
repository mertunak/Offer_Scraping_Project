import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/widget/alert/update_profile_alert.dart';
import 'package:mobile_app/product/widget/column_divider.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends BaseState<ProfileView> {
  bool light = true;
  bool _notificationsEnabled = true;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        title: const Text("Profil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.MEDIUM_H,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppPaddings.MEDIUM_V + AppPaddings.SMALL_H,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 133, 200, 137),
                  borderRadius: AppBorderRadius.MEDIUM,
                  border: Border.all(
                    color: const Color.fromARGB(20, 133, 200, 137),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mert Kurnaz",
                            style: TextStyles.MEDIUM_B,
                          ),
                          Text(
                            "mert.tuna.kurnaz@gmail.com",
                            style: TextStyles.SMALL,
                          ),
                          Text(
                            "Üyelik Tarihi: 23.12.2023",
                            style: TextStyles.SMALL,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          buildIconButton(() {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return UpdateProfileAlert(
                                  width: dyanmicWidthDevice(0.8),
                                  height: dynamicHeightDevice(0.65),
                                );
                              },
                            );
                          }, Icons.edit),
                          const SizedBox(
                            height: 10,
                          ),
                          buildIconButton(() async {
                            await SharedManager.clearData();
                            // ignore: use_build_context_synchronously
                            await authService.signOut(context);
                          }, Icons.logout_outlined),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const ColumnDivider(verticalOffset: 5, horizontalOffset: 0),
              const Text(
                "Ayarlar",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
              ),
              ExpansionTile(
                tilePadding: AppPaddings.SMALL_H,
                childrenPadding: AppPaddings.SMALL_H,
                title: const Text(
                  'Bildirimler',
                  style: TextStyle(fontSize: 20),
                ),
                initiallyExpanded: true,
                collapsedBackgroundColor:
                    const Color.fromARGB(15, 133, 200, 137),
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Color.fromARGB(20, 133, 200, 137),
                      width: 2,
                    )),
                backgroundColor: const Color.fromARGB(15, 133, 200, 137),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Color.fromARGB(20, 133, 200, 137),
                      width: 2,
                    )),
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              activeColor: AssetColors.SECONDARY_COLOR,
                              thumbIcon: MaterialStateProperty.resolveWith(
                                (states) => const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                              title: const Text('Bildirimler Açık/Kapalı'),
                              value: _notificationsEnabled,
                              onChanged: _toggleNotifications,
                            ),
                            SwitchListTile(
                              activeColor: AssetColors.SECONDARY_COLOR,
                              thumbIcon: MaterialStateProperty.resolveWith(
                                (states) => const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                              title: const Text('Yeni Eklenen Siteleri Bildir'),
                              value: _notificationsEnabled,
                              onChanged: _toggleNotifications,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  CircleAvatar buildIconButton(void Function() onPressed, IconData icon) {
    return CircleAvatar(
      backgroundColor: AssetColors.SECONDARY_COLOR,
      radius: 20,
      child: IconButton(
        highlightColor: Colors.transparent,
        padding: EdgeInsets.zero,
        iconSize: 30,
        icon: Icon(
          icon,
          color: AssetColors.PRIMARY_COLOR,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class SettingSwitch extends StatefulWidget {
  final String settingName;
  const SettingSwitch({
    super.key,
    required this.settingName,
  });

  @override
  State<SettingSwitch> createState() => _SettingSwitchState();
}

class _SettingSwitchState extends State<SettingSwitch> {
  bool light = true;
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(
          Icons.check,
          color: AssetColors.PRIMARY_COLOR,
        );
      }
      return const Icon(Icons.close);
    },
  );
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.settingName,
          style: TextStyles.SMALL,
        ),
        Switch(
          thumbIcon: thumbIcon,
          value: light,
          activeColor: AssetColors.SECONDARY_COLOR,
          onChanged: (bool value) {
            setState(() {
              light = value;
            });
          },
        ),
      ],
    );
  }
}
