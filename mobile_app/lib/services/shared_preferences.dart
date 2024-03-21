import 'package:shared_preferences/shared_preferences.dart';

class SharedManager {
  static SharedPreferences? _sharedPreferences;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences;
  }

  static Future<void> saveUserInformation(String key, String value) async {
    await _sharedPreferences?.setString(key, value);
  }

  static Future<void> saveUserInformations(
      String key, List<String> values) async {
    await _sharedPreferences?.setStringList(key, values);
  }

  static List<String>? getUserInformations(String key) {
    return _sharedPreferences?.getStringList(key);
  }

  static String? getString(String key) {
    return _sharedPreferences?.getString(key);
  }

  static Future<void> clearData() async {
    _sharedPreferences?.clear();
  }

  bool validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value) ? true : false;
  }

  static Future<bool> checkIsFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? false;
    return isFirstTime;
  }

  static Future<void> setIsFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', value);
  }
}
