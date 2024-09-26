import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class JWT {
  static final JWT _singleton = JWT._internal();

  JWT._internal();

  factory JWT() {
    return _singleton;
  }

  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _token = "";
  String _refresh = "";
  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  String get token => _token;

  void _setToken(String s) {
    _token = s;
    _prefs.then((prefs) {
      prefs.setString("token", s);
    });
  }

  void _setRefresh(String s) {
    _refresh = s;
    _prefs.then((prefs) {
      prefs.setString("refresh", s);
    });
  }

  Future<bool> checkToken() async {
    var pref = await _prefs;
    try {
      _refresh = pref.getString("refresh")!;
      _token = pref.getString("token")!;
      _loggedIn = true;
    } catch (_) {
      _loggedIn = false;
      return false;
    }

    refreshToken().then((value) {
      _setToken(value);
    }, onError: (e) {
      pref.clear();
      _loggedIn = false;
    });
    return _loggedIn;
  }

  Future<void> logout() async {
    _loggedIn = false;
    var pref = await _prefs;
    pref.clear();
    return;
  }

  Future<bool> login(String username, String password) async {
    _loggedIn = false;
    Uri uri = Uri.parse("${Config.baseUrl}/auth/jwt/token");
    var response = await http
        .post(uri, body: {"username": username, "password": password});
    if (response.statusCode > 299) {
      return false;
    }
    var body = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    _setToken(body["access"]);
    _setRefresh(body["refresh"]);
    _loggedIn = true;
    return true;
  }

  // ret a access token
  Future<String> refreshToken() async {
    var pref = await _prefs;
    try {
      _setRefresh(pref.getString("refresh")!);
    } catch (e) {
      throw ("not logged in");
    }

    var response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/jwt/refresh"),
        body: {"refresh": _refresh});
    if (response.statusCode > 299) {
      throw Exception("failed to refresh");
    }
    var body = json.decode(utf8.decode(response.bodyBytes)) as Map;
    _setToken(body["access"]);
    return _token;
  }
}
