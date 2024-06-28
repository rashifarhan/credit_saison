//helper class for saving key value data in shared preference
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  final SharedPreferences sharedPreference;

  PreferenceManager({required this.sharedPreference});

  void setStringValue(String key, String value) {
    sharedPreference.setString(key, value);
  }

  String? getStringValue(String key) {
    return sharedPreference.getString(key);
  }

  Future<void> setIntValue(String key, int value) async {
    sharedPreference.setInt(key, value);
  }

  int? getintValue(String key) {
    return sharedPreference.getInt(key);
  }

  Future<void> setBoolValue(String key, bool value) async {
    sharedPreference.setBool(key, value);
  }

  bool? getBoolValue(String key) {
    return sharedPreference.getBool(key);
  }
  

  
}
