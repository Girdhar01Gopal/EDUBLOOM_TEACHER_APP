import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../res/app_url.dart';

import '../models/routeno.dart';
import '../models/route_point_model.dart';
import '../models/session_model.dart';
import '../utils/app_snackbar.dart';

class RoutePointController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxBool isListLoading = false.obs;

  String schoolId = "";

  final routes = <RouteData>[].obs;
  final selectedRoute = Rx<RouteData?>(null);

  final TextEditingController stoppageController = TextEditingController();

  final routePoints = <RoutePoint>[].obs;

  final RxString session = ''.obs;

  // ✅ CHANGE 1: sessionList add karo
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  final String postUrl =
      "https://playschool.edubloom.in/api/MasterApp/PostRoutePointApp";

  final String getRoutePointBaseUrl =
      "https://playschool.edubloom.in/api/MasterApp/GetRoutepointApp";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found");
      return;
    }

    // ✅ CHANGE 2: hardcoded line hatao, fetchSessionList add karo
    await fetchSessionList();

    await fetchRoutes();
    await fetchRoutePoints();
  }

  // ✅ CHANGE 3: naya method add karo
  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}$schoolId",
      );
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final model = SessionModel.fromJson(data);
        final list = model.listData ?? [];

        sessionList.value = list
            .map((s) => s.session ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        final current = model.currentSession?.session?.trim();
        if (current != null && current.isNotEmpty) {
          session.value = current;
        } else if (sessionList.isNotEmpty) {
          session.value = sessionList.first;
        }
      } else {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "Session fetch failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      debugPrint("Session fetch error: $e");
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isSessionLoading(false);
    }
  }

  // ══════════════════════════════════════════
  // BAAKI SAB EXACT SAME — EK LINE NAHI BADI
  // ══════════════════════════════════════════

  @override
  void onClose() {
    stoppageController.dispose();
    super.onClose();
  }

  Future<void> fetchRoutes() async {
    try {
      isLoading(true);

      final url =
      Uri.parse('${AppUrl.base_url}api/StudentApp/GetRouteApp/$schoolId');

      final res =
      await http.get(url, headers: {'Content-Type': 'application/json'});

      if (res.statusCode == 200) {
        final jsonResponse = json.decode(res.body);
        final routeResponse = RouteResponse.fromJson(jsonResponse);

        routes.value = routeResponse.data;

        if (routes.isNotEmpty) {
          selectedRoute.value = routes.first;
        } else {
          selectedRoute.value = null;
        }
      } else {
        AppSnackbar.apiError(
          "Failed to fetch routes: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addRoutePoint() async {
    final route = selectedRoute.value;
    final pickupPoint = stoppageController.text.trim();

    if (route == null) {
      AppSnackbar.error("Please select Route No", title: "Validation");
      return;
    }
    if (pickupPoint.isEmpty) {
      AppSnackbar.error("Please enter stoppage name", title: "Validation");
      return;
    }

    try {
      isPosting(true);

      final body = {
        "routePointId": 0,
        "routeNo": route.routeNo,
        "pickupPoint": pickupPoint,
        "action": "1",
        "schoolId": schoolId,
        "createBy": "Admin",
        "updateBy": "Admin",
      };

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> jsonMap = jsonDecode(res.body);
        final String msg = (jsonMap["messages"] ?? "").toString();
        final String data = (jsonMap["data"] ?? "").toString();

        final bool ok =
            data.toUpperCase() == "SUCCESS" || msg.toLowerCase().contains("success");

        if (ok) {
          AppSnackbar.success(msg.isEmpty ? "Route point added" : msg);
          stoppageController.clear();
          await fetchRoutePoints();
        } else {
          // Server ka message technical hua to automatically "Something went wrong" ban jayega
          AppSnackbar.error(msg.isEmpty ? "Route point add failed" : msg, title: "Failed");
        }
      } else {
        AppSnackbar.apiError(
          "PostRoutePoint failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  Future<void> fetchRoutePoints() async {
    try {
      isListLoading(true);

      final url = Uri.parse('${getRoutePointBaseUrl}/$schoolId');
      print('Fetching Route Points from $url');
      final res =
      await http.get(url, headers: {'Content-Type': 'application/json'});

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        final parsed = RoutePointResponse.fromJson(jsonResponse);

        final list = parsed.data.toList()
          ..sort((a, b) {
            final rn = a.routeNo.compareTo(b.routeNo);
            if (rn != 0) return rn;
            return b.createDate.compareTo(a.createDate);
          });

        routePoints.value = list;
      } else {
        AppSnackbar.apiError(
          "Failed to fetch route points: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isListLoading(false);
    }
  }

  Future<void> editRoutePoint({
    required int routePointId,
    required int routeNo,
    required String pickupPoint,
  }) async {
    if (pickupPoint.trim().isEmpty) {
      AppSnackbar.error("Pickup point cannot be empty", title: "Validation");
      return;
    }

    try {
      isPosting(true);

      final body = {
        "routePointId": routePointId,
        "routeNo": routeNo,
        "pickupPoint": pickupPoint.trim(),
        "action": "1",
        "schoolId": schoolId,
        "createBy": "Admin",
        "updateBy": "Admin",
      };

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> jsonMap = jsonDecode(res.body);
        final String msg = (jsonMap["messages"] ?? "").toString();
        final String data = (jsonMap["data"] ?? "").toString();

        final bool ok =
            data.toUpperCase() == "SUCCESS" || msg.toLowerCase().contains("success");

        if (ok) {
          Get.back();
          AppSnackbar.success(msg.isEmpty ? "Route point updated" : msg);
          await fetchRoutePoints();
        } else {
          AppSnackbar.error(msg.isEmpty ? "Update failed" : msg, title: "Failed");
        }
      } else {
        AppSnackbar.apiError(
          "Update failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }
}