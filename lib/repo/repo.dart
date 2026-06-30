import 'dart:core';

import 'package:flutter/foundation.dart';

import '../data/network/base_api_response.dart';
import '../data/network/network_api_response.dart';
import '../res/app_url.dart';

class LoginRepository {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> loginApi({
    required var data,
  }) async {
    try {
      dynamic response = await _apiServices.postApi(
          data, "${AppUrl.base_url}${AppUrl.loginUrl}");
      if (kDebugMode) {
        print(" ye too response hai bhai   ${response}");
        print(" api  ${AppUrl.base_url}${AppUrl.loginUrl}");
      }
      return response;
    } catch (e) {
      throw FormatException("Exception error in login repo  ${e.toString()}");
      //throw FormatException("Exception error in login repo  ${e.toString}");
    }
  }
}

class EnquiryRepository {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> enquiryApi({
    required var data,
    required var baseUrl,
  }) async {
    try {
      dynamic response = await _apiServices.postApi(
        data,
        "$baseUrl${AppUrl.postenquiryUrl}",
      );
      if (kDebugMode) {
        print(" ye too response hai bhai   ${response}");
      }
      return response;
    } catch (e) {
      throw FormatException("Exception error in enquiry repo  ${e.toString()}");
      //throw FormatException("Exception error in enquiry repo  ${e.toString}");
    }
  }
}