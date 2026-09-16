import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../app_exception.dart';
import 'api_result.dart';
import 'base_api_response.dart';

class NetworkApiServices extends BaseApiServices {
  /// Poore app ke liye ek hi shared client — har request par naya
  /// TCP+TLS handshake nahi hoga (http.get/http.post internally wahi
  /// karte hain). Screens ka slow load hone ka sabse bada reason yahi tha.
  static final http.Client _client = http.Client();

  static const _timeout = Duration(seconds: 10);

  // ---------------------------------------------------------------
  // Purane methods (legacy) — jo screens abhi getApi/postApi use kar
  // rahi hain wo bina change ke chalti rahengi.
  // ---------------------------------------------------------------

  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) print(url);

    dynamic responseJson;
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException("");
    } on TimeoutException {
      throw RequestTimeOut("");
    }
    return responseJson;
  }

  @override
  Future<dynamic> postApi(dynamic data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    try {
      final response = await _client.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: const <String, String>{
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException("Internet exception ");
    } on TimeoutException {
      throw RequestTimeOut("server request exception");
    }
    if (kDebugMode) print(" response json $responseJson");
    return responseJson;
  }

  // ---------------------------------------------------------------
  // Naye ApiResult based methods
  // ---------------------------------------------------------------

  @override
  Future<ApiResult> getJson(String url, {Map<String, String>? headers}) async {
    try {
      final response =
      await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
      final result = _toResult(response);

      // Is backend ke kuch GET/list endpoints galti se HTTP 409 ("duplicate")
      // return karte hain jabki data bilkul sahi aata hai. Read par duplicate
      // ka koi matlab hi nahi. Agar body me listData present hai to use
      // success maan lo, warna valid data discard ho jata hai.
      if (result.isDuplicate) {
        final body = result.data;
        if (body is Map<String, dynamic> && body['listData'] != null) {
          return ApiResult(
            isSuccess: true,
            isDuplicate: false,
            statusCode: result.statusCode,
            message: result.message,
            data: result.data,
          );
        }
      }

      return result;
    } on SocketException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "No internet connection",
      );
    } on TimeoutException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "Request timed out",
      );
    } catch (e) {
      return ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResult> postJson(
      String url,
      dynamic body, {
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json', ...?headers},
      ).timeout(_timeout);
      return _toResult(response);
    } on SocketException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "No internet connection",
      );
    } on TimeoutException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "Request timed out",
      );
    } catch (e) {
      return ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResult> putJson(
      String url,
      dynamic body, {
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json', ...?headers},
      ).timeout(_timeout);
      return _toResult(response);
    } on SocketException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "No internet connection",
      );
    } on TimeoutException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "Request timed out",
      );
    } catch (e) {
      return ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResult> postMultipart(
      String url, {
        required Map<String, String> fields,
        List<MultipartFileInput> files = const [],
        Map<String, String>? headers,
      }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(fields);
      if (headers != null) request.headers.addAll(headers);

      for (final f in files) {
        request.files.add(await http.MultipartFile.fromPath(
          f.fieldName,
          f.filePath,
          filename: f.filename,
        ));
      }

      final streamedResponse = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _toResult(response);
    } on SocketException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "No internet connection",
      );
    } on TimeoutException {
      return const ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: "Request timed out",
      );
    } catch (e) {
      return ApiResult(
        isSuccess: false,
        isDuplicate: false,
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------

  /// Ek hi jagah decide hota hai ki call "actually" success hui ya nahi —
  /// sirf HTTP status par bharosa na karke real body bhi check karta hai.
  ///
  /// Is backend ke saare endpoints JSON object return nahi karte, kuch raw
  /// array bhejte hain. `decoded` body ka original shape rakhta hai;
  /// `asMap` tabhi non-null hoga jab body object ho, kyunki isSuccess/
  /// message sirf wahi dhoondhne ka matlab banta hai.
  ApiResult _toResult(http.Response response) {
    if (kDebugMode) {
      print("[${response.request?.url}] status=${response.statusCode} "
          "body=${response.body}");
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    final Map<String, dynamic>? asMap =
    decoded is Map<String, dynamic> ? decoded : null;

    final message = (asMap?['messages'] ??
        asMap?['message'] ??
        asMap?['Messages'] ??
        asMap?['Message'])
        ?.toString();

    if (response.statusCode == 409) {
      return ApiResult(
        isSuccess: false,
        isDuplicate: true,
        statusCode: 409,
        message: message?.isNotEmpty == true
            ? message!
            : "This record already exists",
        data: decoded,
      );
    }

    final okStatus = response.statusCode == 200 || response.statusCode == 201;

    // Kuch endpoints 200 par `isSuccess` bhejte hi nahi — use success maano;
    // sirf explicit `isSuccess: false` hi fail karega. Jo body object hi
    // nahi hai (raw array / rows ki list) wo isSuccess:false carry kar hi
    // nahi sakti, to wo bhi success hai.
    final bodySaysSuccess = asMap == null || asMap['isSuccess'] != false;

    return ApiResult(
      isSuccess: okStatus && bodySaysSuccess,
      isDuplicate: false,
      statusCode: response.statusCode,
      message: message?.isNotEmpty == true
          ? message!
          : (okStatus && bodySaysSuccess
          ? "Success"
          : "Server returned ${response.statusCode}"),
      data: decoded,
    );
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final dynamic responseJson = jsonDecode(response.body);
        if (kDebugMode) {
          print(" response json in return method  $responseJson");
        }
        return responseJson;

      case 400:
        if (kDebugMode) {
          print(" response json in return method case 400  ${response.body}");
        }
        throw InvalidUrlException("Bad request (400)");

      default:
        if (kDebugMode) {
          print(" response json in return method case default ${response.body}");
        }
        throw FetchDataException(
            "Error occured in server ${response.statusCode}");
    }
  }
}