import 'dart:convert';

import 'package:app/api/api_client.dart';
import 'package:app/model/user_info.dart';

class ApiManager {
  ApiManager();

  Future<UserInfo?> loginUser(String userName, String password) async {
    var reqBody = <String, dynamic> {
      'userName': userName,
      'password': password
    };
    var response = await ApiClient.instance.postRequest('/login', reqBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonRes = json.decode(response.body);
      var user = jsonRes["user"];
      return UserInfo.fromJson(user);
    } else {
      return null;
    }
  }

  Future<List<UserInfo>> getAllUsers() async {
    var response = await ApiClient.instance.getRequest('/user');
    if (response.statusCode == 200) {
      var jsonRes = json.decode(response.body);
      var userJson = jsonRes["_embedded"];
      return List<UserInfo>.from(userJson["user"].map((x) => UserInfo.fromJson(x)));
    } else {
      return [];
    }
  }

  Future<UserInfo?> getUser(String id) async {
    var response = await ApiClient.instance.getRequest('/user/$id');
    if (response.statusCode == 200) {
      return UserInfo.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  // return user id
  Future<String?> registerUser(UserInfo userModel) async {
    var reqBody = userModel.toJson();
    var response = await ApiClient.instance.postRequest('/user', reqBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var resHeaders = response.headers;
      print(resHeaders);
      String? newUserPath = resHeaders["location"];
      if (newUserPath != null && newUserPath.isNotEmpty) {
        Uri url = Uri.parse(newUserPath);
        print(url.pathSegments);
        return url.pathSegments.last;
      } else {
        return null;
      }

    } else {
      return null;
    }
  }

  Future<bool> updateUser(UserInfo userModel) async {
    var reqBody = userModel.toJson();
    var response = await ApiClient.instance.putRequest('/user/${userModel.id}', reqBody);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateDeviceToken(String userId, String fcmToken) async {
    var reqBody = <String, dynamic> {
      'deviceToken': fcmToken,
    };

    var response = await ApiClient.instance.patchRequest('/user/$userId', reqBody);
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAvatarInfo(String userId, String avatarName, String avatarImage) async {
    var reqBody = <String, dynamic> {
      'avatarName': avatarName,
      'avatarImage': avatarImage,
    };

    var response = await ApiClient.instance.patchRequest('/user/$userId', reqBody);
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateUserScore(String userId, int score) async {
    var reqBody = <String, dynamic> {
      'score': score,
    };

    var response = await ApiClient.instance.patchRequest('/user/$userId', reqBody);
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }
}