import 'package:shared_preferences/shared_preferences.dart';

class CitySharedPreference {
  Future<bool> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("selectedCity", token);
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("selectedCity") ?? '';
  }
}