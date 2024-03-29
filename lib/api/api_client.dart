import 'dart:convert';

import 'package:app/util/app_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiClient {

  Future<http.Response> getRequest(String apiEndPoint) async {
    var url = Uri.parse(Uri.encodeFull('${AppConstant.baseURL}$apiEndPoint'));
    final http.Response response = await http.get(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppCache.instance.authToken}',
      },
    );
    debugPrint('${response.request?.url.toString()}; ${response.statusCode}; ${response.body}');
    return response;
  }

  Future<http.Response> postRequest(String apiEndPoint, Map<String, dynamic> body) async {
    var url = Uri.parse(Uri.encodeFull('${AppConstant.baseURL}$apiEndPoint'));
    final http.Response response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppCache.instance.authToken}',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> putRequest(String apiEndPoint, Map<String, dynamic> body) async {
    var url = Uri.parse(Uri.encodeFull('${AppConstant.baseURL}$apiEndPoint'));
    final http.Response response = await http.put(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppCache.instance.authToken}',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> patchRequest(String apiEndPoint, Map<String, dynamic> body) async {
    var url = Uri.parse(Uri.encodeFull('${AppConstant.baseURL}$apiEndPoint'));
    final http.Response response = await http.patch(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppCache.instance.authToken}',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  ApiClient._privateConstructor();
  static final ApiClient instance = ApiClient._privateConstructor();
}

class ApiResponse {
  String body;
  int statusCode;
  String errorMessage;

  ApiResponse(this.body, this.statusCode, this.errorMessage);
}