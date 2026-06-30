import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../app_exception.dart';
import 'base_api_response.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException("");
    } on RequestTimeOut {
      throw RequestTimeOut("");
    }
    return responseJson;
  }

  Future<dynamic> postApi(var data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json',
          // Add any other headers you might need
        },
      ).timeout(Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException("Internet exception ");
    } on RequestTimeOut {
      throw RequestTimeOut("server request exception");
    }
    if (kDebugMode) {
      print(" response json ${responseJson}");
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        if (kDebugMode) {
          print(" response json in return method  ${responseJson}");
        }
        return responseJson;
      case 400:
        if (kDebugMode) {
          print(
              " response json in return method case 400  ${jsonDecode(response.body)}");
        }
        throw InvalidUrlException;

      default:
        if (kDebugMode) {
          print(
              " response json in return method  case default${jsonDecode(response.body)}");
        }

        throw FetchDataException(
            "Error occured in server" + response.statusCode.toString());
    }
  }
}
