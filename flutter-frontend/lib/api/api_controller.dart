import 'dart:convert';
import 'dart:html';

import 'package:admin/models/authentication_data.dart';
import 'package:admin/models/document.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../managers/rest_manager.dart';
import '../models/file_data_model.dart';
import '../models/user.dart';
import '../support/constants.dart';

class ApiController {
  static final ApiController _singleton = ApiController._internal();

  factory ApiController() {
    return _singleton;
  }

  ApiController._internal();

  RestManager _restManager = RestManager();


  Future<AuthenticationData> login(String email, String password) async {
      Map<String, dynamic> params = Map();
      params["grant_type"] = "password";
      params["client_id"] = CLIENT_ID;
      params["client_secret"] = CLIENT_SECRET;
      params["username"] = email;
      params["password"] = password;
      String result = (await _restManager.makePostRequest(
          ADDRESS_AUTHENTICATION_SERVER, REQUEST_LOGIN, params,
          type: TypeHeader.urlencoded, httpsEnabled: false))
          .body;
      AuthenticationData _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
      _restManager.token = _authenticationData.accessToken!;
      return _authenticationData;
  }

  Future<AuthenticationData> refreshToken(String refreshToken) async {
    Map<String, dynamic> params = Map();
    params["grant_type"] = "refresh_token";
    params["client_id"] = CLIENT_ID;
    params["client_secret"] = CLIENT_SECRET;
    params["refresh_token"] = refreshToken;
    Response response = await _restManager.makePostRequest(
        ADDRESS_AUTHENTICATION_SERVER, REQUEST_LOGIN, params,
        type: TypeHeader.urlencoded, httpsEnabled: false);
    String result = response.body;
    AuthenticationData _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
    _restManager.token = _authenticationData.accessToken!;
    if(response.statusCode == HttpStatus.badRequest)
      _authenticationData.error = "BAD REQUEST";
    return _authenticationData;
  }

  Future<Response> logout(String refreshToken) async {
    Map<String, dynamic> params = Map();
    _restManager.token = null;
    // _persistentStorageManager.setString('token', null);
    params["client_id"] = CLIENT_ID;
    params["client_secret"] = CLIENT_SECRET;
    params["refresh_token"] = refreshToken;
    Response response = await _restManager.makePostRequest(
        ADDRESS_AUTHENTICATION_SERVER, REQUEST_LOGOUT, params,
        type: TypeHeader.urlencoded, httpsEnabled: false);
    return response;
  }

  // USER
  Future<User?> newUser(User user, String pwd) async {
    Map<String, String> params = Map();
    params["pwd"] = pwd;
    try {
      Response response = await _restManager.makePostRequest(
          ADDRESS_STORE_SERVER, REQUEST_NEW_USER, user,
          value: params);
      if (response.statusCode == HttpStatus.created) {
        return User.fromJson(json.decode(response.body));
      } else
        return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> loadUserLoggedData() async {
    Response? response;
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_LOAD_USER);
      if (response.statusCode == HttpStatus.notFound) return null;
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('statusCode: '+ response!.statusCode.toString());
      print("loadUser: " + e.toString());
    }
  }

  Future<List<Document>?> loadRecentFilesOwned() async {
    Response? response;
    try {
      response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_LOAD_RECENT_FILES);
      print(response.body);
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: false);
      return List<Document>.from(json
            .decode(response.body)
            .map((i) => Document.fromJson(i))
            .toList());
    } catch (e) {
      print('statusCode: '+ response!.statusCode.toString());
      print("loadUser: " + e.toString());
    }
    return null;
  }

  Future<List<Document>?> loadRecentFilesReadOnly() async {
    Response? response;
    try {
      response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_LOAD_RECENT_FILES_READ_ONLY);
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: false);
      return List<Document>.from(json
          .decode(response.body)
          .map((i) => Document.fromJson(i))
          .toList());
    } catch (e) {
      print('statusCode: '+ response!.statusCode.toString());
      print("loadUser: " + e.toString());
    }
    return null;
  }


Future<User?> searchUserByEmail(String email) async {
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SEARCH_USER_BY_EMAIL + "/" + email);
      if (response.statusCode == HttpStatus.notFound) return null;
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("searchUserByEmail exception: " + e.toString());
      return null;
    }
  }

  Future<User?> searchUserByEmailContains(String email) async {
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SEARCH_USER_BY_EMAIL_CONTAINS + "/" + email);
      if (response.statusCode == HttpStatus.notFound) return null;
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("searchUserByEmail exception: " + e.toString());
      return null;
    }
  }

  Future<StreamedResponse?> uploadFiles(List<FileDataModel> files) async{
    late StreamedResponse response;
    try {
       response = await _restManager.makeMultiPartRequest(
          ADDRESS_STORE_SERVER, REQUEST_UPLOAD_FILES, files);
    }catch(e){
      print("uploadFiles exception: "+e.toString());
      return null;
    }
    return response;
  }

  Future<StreamedResponse?> uploadFile(FileDataModel file) async{
    late StreamedResponse response;
    try {
      response = await _restManager.makeMultiPartRequest(
          ADDRESS_STORE_SERVER, REQUEST_UPLOAD_FILE, file);
    }catch(e){
      print("uploadFiles exception: "+e.toString());
      return null;
    }
    return response;
  }

  Future<Response?> addReaders(List<Document> document, List<User> user) async{
    try {
      Map<String, dynamic> params = Map();
      params["files_id"] = document.map((d) => d.id.toString());
      params["readers_id"] = user.map((u) => u.id);
      Response response = await _restManager.makePutRequest(
        ADDRESS_STORE_SERVER, REQUEST_ADD_READERS, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      return response;
    } catch (e) {
      print("addReaders exception: " + e.toString());
      return null;
    }
  }


}

