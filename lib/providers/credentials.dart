import 'package:e14_station/classes/login_cooldown.dart';
import 'package:e14_station/utils/login_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginToken extends ChangeNotifier {
  String token = "", name = "";
  bool signingIn = false;
  bool signedIn = false;
  LoginCooldown? cooldownDetails;

  LoginToken() {
    initialize();
  }

  initialize() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    name = prefs.getString("name") ?? "";

    signedIn = token != "";

    notifyListeners();
  }

  login(String accountName, String password, BuildContext context) async {
    signingIn = true;
    notifyListeners();
    var response = await requestLogin(accountName, password);
    if (response["result"]) {
      token = response["token"];
      name = response["name"];
      signedIn = true;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(response["reason"])));
      }
    }
    signingIn = false;
    notifyListeners();
  }

  signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    signedIn = false;
    notifyListeners();
  }

  // Use this only when there's no internet connection or something is wrong with the server.
  signOutUnsafe() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    signedIn = false;
    notifyListeners();
  }
}
