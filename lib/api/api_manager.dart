import 'dart:convert';

import 'package:app/api/api_client.dart';
import 'package:app/model/user_info.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  ApiManager();

      Future<bool> sendFeedback(String userId, String feedbackText) async {
    try {
      var reqBody = <String, dynamic>{
        'userId': userId,
        'feedback': feedbackText,
      };

      var response = await ApiClient.instance.postRequest('/feedback', reqBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Handle errors here
      print('Error sending feedback: $error');
      return false;
    }
  }

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

  Future<List<UserInfo>> getAllUsersByTeam(String teamName) async {
    var response = await ApiClient.instance.getRequest('/users?teamName=$teamName');
    if (response.statusCode == 200) {
      var jsonRes = json.decode(response.body);
      var userJson = jsonRes["records"];
      return List<UserInfo>.from(userJson.map((x) => UserInfo.fromJson(x)));
    } else {
      return [];
    }
  }

  Future<bool> checkIfUserNameAvailable(String userName) async {
    var response = await ApiClient.instance.getRequest('/check-userName?userName=$userName');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfTeamIsActive(String teamName) async {
    var response = await ApiClient.instance.getRequest('/team/check?teamName=$teamName');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
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
    var reqBody = userModel.toUpdateJson();
    var response = await ApiClient.instance.patchRequest('/user/${userModel.id}', reqBody);

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

  Future<bool> updateTeamName(String userId, String teamName) async {
    var reqBody = <String, dynamic> {
      'teamName': teamName,
    };

    var response = await ApiClient.instance.patchRequest('/user/$userId', reqBody);
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAvatarInfo(String userId, String avatarImage) async {
    var reqBody = <String, dynamic> {
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

Future<String> fetchDataForKeyword(String keyword) async {
    var apiEndPoint = 'https://api.datamuse.com/words?ml=$keyword&v=de';
    var url = Uri.parse(Uri.encodeFull(apiEndPoint));
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      // Hier kannst du Fehlerbehandlung hinzufügen, wenn die API-Anfrage fehlschlägt
      return 'Fehler beim Abrufen von Daten für Keyword: $keyword';
    }
  }


