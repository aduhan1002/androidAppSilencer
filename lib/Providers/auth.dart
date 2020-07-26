import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  static const String signupUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyALRXKpfflvGLABE5vzDqK9Xavl4OfvK1g';
  static const String loginUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyALRXKpfflvGLABE5vzDqK9Xavl4OfvK1g';
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(
          DateTime.now(),
        )) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, bool logginIn) async {
    try {
      final response = await http.post(
        logginIn ? loginUrl : signupUrl,
        body: json.encode(
          {
            'email': email.trim(),
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw Exception(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toString(),
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return authenticate(email, password, false);
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, true);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return false;
    _userId=extractedUserData['userId'];
    _expiryDate=expiryDate;
    _token=extractedUserData['token'];
    _autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> logout() async{
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs= await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }
}
