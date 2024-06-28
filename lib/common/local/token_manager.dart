
//Manage all operations related to token save and retrieve

import 'package:base_framework/common/local/preference_manager.dart';

class TokenManager {
  // ignore: constant_identifier_names
  static const String KEY_TOKEN = "token";

  final PreferenceManager preferenceManager;
  // ignore: empty_constructor_bodies
  TokenManager({required this.preferenceManager}) {}

  Future<void> saveToken(String token) async {
    preferenceManager.setStringValue(KEY_TOKEN, token);
  }

  Future<String?> getToken() async {
    return preferenceManager.getStringValue(KEY_TOKEN);
  }
  

  

}
