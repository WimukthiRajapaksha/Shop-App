import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/model/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    print("Is auth ${this.authToken != null}");
    return this.authToken != null;
  }

  String? get authToken {
    print(this._expiryDate);
    print(this._token);
    if (this._expiryDate != null &&
        this._expiryDate!.isAfter(DateTime.now()) &&
        this._token != null) {
      return this._token;
    }
    return null;
  }

  String? get userId {
    return this._userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCyPV7vowqAYfy8XH-wuP69lBQAhoC8NY4";
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(msg: responseData["error"]["message"]);
      }
      print(responseData);
      this._token = responseData["idToken"];
      this._userId = responseData["localId"];
      this._expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );
      this._autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": this._token,
        "userId": this._userId,
        "expiryDate": this._expiryDate!.toIso8601String(),
      });
      prefs.setString("userData", userData);
      print("-------+++++++");
      prefs.getString("userData");
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("-----++-----");
      print(prefs.getString("userData"));
      if (prefs.getString("userData") == null) {
        print("Null");
        return false;
      }
      print("Not null");
      final extractedUserData =
          json.decode(prefs.getString("userData")!) as Map<String, dynamic>;
      print(extractedUserData);
      print(DateTime.parse(extractedUserData["expiryDate"] as String));

      final expiryDate =
          DateTime.parse(extractedUserData["expiryDate"] as String);
      if (expiryDate.isBefore(DateTime.now())) {
        print("Is Before");
        return false;
      }
      this._token = extractedUserData["token"] as String;
      this._userId = extractedUserData["userId"] as String;
      this._expiryDate = expiryDate;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> signUp(String email, String password) async {
    this._authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    this._authenticate(email, password, "signInWithPassword");
  }

  Future<void> logout() async {
    this._token = null;
    this._userId = null;
    this._expiryDate = null;
    if (this._authTimer != null) {
      this._authTimer!.cancel();
      this._authTimer = null;
    }
    notifyListeners();
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.clear();
  }

  void _autoLogout() {
    if (this._authTimer != null) {
      this._authTimer!.cancel();
    }
    final timeToExpiry = this._expiryDate!.difference(DateTime.now()).inSeconds;
    this._authTimer = Timer(Duration(seconds: timeToExpiry), this.logout);
  }
}
