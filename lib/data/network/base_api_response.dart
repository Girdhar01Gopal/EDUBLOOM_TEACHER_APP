import 'api_result.dart';

abstract class BaseApiServices {
  // ---- Purane methods (jo pehle se use ho rahe hain, waise ke waise) ----
  Future<dynamic> getApi(String url);

  Future<dynamic> postApi(dynamic data, String url);

  // ---- Naye ApiResult based methods ----
  Future<ApiResult> getJson(String url, {Map<String, String>? headers});

  Future<ApiResult> postJson(
      String url,
      dynamic body, {
        Map<String, String>? headers,
      });

  Future<ApiResult> putJson(
      String url,
      dynamic body, {
        Map<String, String>? headers,
      });

  Future<ApiResult> postMultipart(
      String url, {
        required Map<String, String> fields,
        List<MultipartFileInput> files,
        Map<String, String>? headers,
      });
}