import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../res/app_url.dart';

import '../models/routeno.dart';
import '../models/route_point_model.dart';
import '../models/session_model.dart';      // ✅ ADD

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
      Get.snackbar("Error", "SchoolId not found");
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
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
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
        Get.snackbar("Error", "Failed to fetch routes: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Route fetch error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addRoutePoint() async {
    final route = selectedRoute.value;
    final pickupPoint = stoppageController.text.trim();

    if (route == null) {
      Get.snackbar("Validation", "Please select Route No");
      return;
    }
    if (pickupPoint.isEmpty) {
      Get.snackbar("Validation", "Please enter stoppage name");
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
          Get.snackbar("Success", msg.isEmpty ? "Route point added" : msg);
          stoppageController.clear();
          await fetchRoutePoints();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Route point add failed" : msg);
        }
      } else {
        Get.snackbar("Error", "PostRoutePoint failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Add route point failed: $e");
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
        Get.snackbar("Error", "Failed to fetch route points: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Route point list error: $e");
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
      Get.snackbar("Validation", "Pickup point cannot be empty");
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
          Get.snackbar("Success", msg.isEmpty ? "Route point updated" : msg);
          await fetchRoutePoints();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Update failed" : msg);
        }
      } else {
        Get.snackbar("Error", "Update failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Edit failed: $e");
    } finally {
      isPosting(false);
    }
  }
}