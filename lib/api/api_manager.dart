import 'dart:convert';

import 'package:app/api/api_client.dart';
import 'package:app/model/user_api_model.dart';

class ApiManager {
  ApiManager();

  Future<List<UserApiModel>> getAllUsers() async {
    var response = await ApiClient.instance.getRequest('/user');
    if (response.statusCode == 200) {
      var jsonRes = json.decode(response.body);
      var userJson = jsonRes["_embedded"];
      return List<UserApiModel>.from(userJson["user"].map((x) => UserApiModel.fromJson(x)));
    } else {
      return [];
    }
  }

  Future<UserApiModel?> getUser(String id) async {
    var response = await ApiClient.instance.getRequest('/user/$id');
    if (response.statusCode == 200) {
      return UserApiModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  // return user id
  Future<String?> registerUser(UserApiModel userModel) async {
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

  Future<bool> updateUser(UserApiModel userModel) async {
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

  Future<bool> updateUserScore(String userId, String score) async {
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