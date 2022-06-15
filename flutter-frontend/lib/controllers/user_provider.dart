import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:admin/api/api_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../UI/screens/auth/login_screen.dart';
import '../managers/persistent_storage_manager.dart';
import '../managers/rest_manager.dart';
import '../models/authentication_data.dart';
import '../models/user.dart';
import '../service/navigation_service.dart';
import '../support/constants.dart';
import '../support/login_result.dart';


enum LoginStatus { Authenticated, Authenticating, Unauthenticated}

class UserProvider with ChangeNotifier{
  static final UserProvider _singleton = UserProvider._internal();

  factory UserProvider() {
    return _singleton;
  }

  UserProvider._internal();

  PersistentStorageManager _persistentStorageManager = PersistentStorageManager();
  ApiController api = new ApiController();
  late AuthenticationData _authenticationData;


  User? _currentUser = DEBUG_MODE? new User(
        id:"user1ID",
        email:"user1@mail.com",
        username: "user1"
    ) : null;

  LoginStatus _loginStatus = DEBUG_MODE ? LoginStatus.Authenticated: LoginStatus.Unauthenticated;

  User? get currentUser => _currentUser;

  LoginStatus get loginStatus => _loginStatus;

  Future<LoginResult> login(String email, String password) async {

    _loginStatus = LoginStatus.Authenticating;
    try {
      if(!DEBUG_MODE){
        _authenticationData = await api.login(email, password);
        if (_authenticationData.hasError()) {
          if (_authenticationData.error == "Invalid user credentials") {
            return LoginResult.error_wrong_credentials;
          } else if (_authenticationData.error == "Account is not fully set up") {
            return LoginResult.error_not_fully_setupped;
          } else {
            return LoginResult.error_unknown;
          }
        }
        _persistentStorageManager.setString(
            STORAGE_REFRESH_TOKEN, _authenticationData.refreshToken!);
        _persistentStorageManager.setString(STORAGE_EMAIL, email);
        _currentUser = await api.loadUserLoggedData();
        Timer.periodic(Duration(seconds: (_authenticationData.expiresIn! - 50)),
            (Timer t) async {
          bool result = await _refreshToken();
          print('refreshToken: $result');
          if (!result) {
            print('refreshToken: cancel Timer.periodic');
            t.cancel();
          }
        });
      }

        _loginStatus = LoginStatus.Authenticated;
        notifyListeners();
        return LoginResult.logged;
    } catch (e) {
      _loginStatus = LoginStatus.Unauthenticated;
      notifyListeners();
      print(e);
      return LoginResult.error_unknown;
    }
  }

  Future<bool> autoLogin() async {
    String? email = await _persistentStorageManager.getString(STORAGE_EMAIL);
    String? refreshToken = await _persistentStorageManager.getString(STORAGE_REFRESH_TOKEN);
    if (refreshToken != null && email != null) {
      _authenticationData = AuthenticationData();
      _authenticationData.refreshToken = refreshToken;
      _loginStatus = LoginStatus.Authenticating;
      bool autoLogInResult = await _refreshToken();
      if (autoLogInResult) {
        _currentUser = await api.loadUserLoggedData();
        _loginStatus = LoginStatus.Authenticated;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> _refreshToken() async {
    try {
      _authenticationData = await api.refreshToken(_authenticationData.refreshToken!);
      if(_authenticationData.hasError()) {
        _loginStatus = LoginStatus.Unauthenticated;
        NavigationService.instance.navigateToReplacement(LoginScreen.routeName);
        _persistentStorageManager.remove(STORAGE_REFRESH_TOKEN);
        _persistentStorageManager.remove(STORAGE_EMAIL);
        _currentUser = null;
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      Response response = await api.logout(_authenticationData.refreshToken!);
      // if (response.statusCode != 200)
      _persistentStorageManager.remove(STORAGE_REFRESH_TOKEN);
      _persistentStorageManager.remove(STORAGE_EMAIL);
      // _persistentStorageManager.setString('token', null);
      _persistentStorageManager.remove('token');
      _currentUser = null;
      _loginStatus = LoginStatus.Unauthenticated;
      return true;
    } catch (e) {
      return false;
    }
  }


}
