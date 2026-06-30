import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/add_route_model.dart';

class RouteMasterController extends GetxController {
  // Add
  final TextEditingController routeNoController = TextEditingController();
  final TextEditingController busNoController = TextEditingController();

  // Edit
  final TextEditingController editRouteNoController = TextEditingController();
  final TextEditingController editBusNoController = TextEditingController();
  final RxInt editingRouteNameId = 0.obs;

  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxBool isUpdating = false.obs;

  final Rxn<RouteModel> routeModel = Rxn<RouteModel>();

  String? schoolId;

  final String getRouteBaseUrl =
      "https://playschool.edubloom.in/api/StudentApp/GetRouteApp/";
  final String postRouteUrl =
      "https://playschool.edubloom.in/api/MasterApp/PostRouteApp";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    if (schoolId == null || schoolId!.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    await fetchRoutes();
  }

  @override
  void onClose() {
    routeNoController.dispose();
    busNoController.dispose();
    editRouteNoController.dispose();
    editBusNoController.dispose();
    super.onClose();
  }

  Future<void> fetchRoutes() async {
    try {
      isLoading(true);
      final url = Uri.parse("$getRouteBaseUrl${Uri.encodeComponent(schoolId!)}");

      final res = await http.get(url, headers: {"Content-Type": "application/json"});

      if (res.statusCode == 200) {
        routeModel.value = RouteModel.fromJson(jsonDecode(res.body));
      } else {
        Get.snackbar("Error", "GetRoute API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch failed: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addRoute() async {
    final routeNoText = routeNoController.text.trim();
    final busNo = busNoController.text.trim();

    if (routeNoText.isEmpty) {
      Get.snackbar("Validation", "Route No is required");
      return;
    }
    final routeNo = int.tryParse(routeNoText);
    if (routeNo == null || routeNo <= 0) {
      Get.snackbar("Validation", "Enter a valid Route No");
      return;
    }
    if (busNo.isEmpty) {
      Get.snackbar("Validation", "Bus No is required");
      return;
    }

    try {
      isPosting(true);

      final body = {
        "routeNameId": 0,
        "routeNo": routeNo,
        "busNo": busNo,
        "createBy": "Admin",
        "schoolId": schoolId,
      };

      final res = await http.post(
        Uri.parse(postRouteUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;

        final msg = (jsonMap["messages"] ?? "").toString();
        final data = (jsonMap["data"] ?? "").toString();

        final ok = data.toUpperCase() == "SUCCESS" || msg.toLowerCase().contains("success");

        if (ok) {
          Get.snackbar("Success", msg.isEmpty ? "Route added" : msg);
          routeNoController.clear();
          busNoController.clear();
          await fetchRoutes();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Route add failed" : msg);
        }
      } else {
        Get.snackbar("Error", "PostRoute API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Add route failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // ✅ EDIT DIALOG
  void openEditDialog(RouteData item) {
    editingRouteNameId.value = item.routeNameId;
    editRouteNoController.text = item.routeNo.toString();
    editBusNoController.text = item.busNo;

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Route"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editRouteNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Route No",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editBusNoController,
              decoration: const InputDecoration(
                labelText: "Bus No",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          Obx(() {
            return ElevatedButton(
              onPressed: isUpdating.value ? null : updateRoute,
              child: isUpdating.value
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Update"),
            );
          }),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ✅ UPDATE (same API)
  Future<void> updateRoute() async {
    final routeNoText = editRouteNoController.text.trim();
    final busNo = editBusNoController.text.trim();

    final routeNo = int.tryParse(routeNoText);
    if (routeNo == null || routeNo <= 0) {
      Get.snackbar("Validation", "Enter a valid Route No");
      return;
    }
    if (busNo.isEmpty) {
      Get.snackbar("Validation", "Bus No is required");
      return;
    }

    try {
      isUpdating(true);

      final body = {
        "routeNameId": editingRouteNameId.value, // ✅ important for edit
        "routeNo": routeNo,
        "busNo": busNo,
        "createBy": "Admin",
        "schoolId": schoolId,
      };

      final res = await http.post(
        Uri.parse(postRouteUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;

        final msg = (jsonMap["messages"] ?? "").toString();
        final data = (jsonMap["data"] ?? "").toString();

        final ok = data.toUpperCase() == "SUCCESS" || msg.toLowerCase().contains("success");

        if (ok) {
          Get.back(); // close dialog
          Get.snackbar("Success", msg.isEmpty ? "Route updated" : msg);
          await fetchRoutes();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Update failed" : msg);
        }
      } else {
        Get.snackbar("Error", "Update API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isUpdating(false);
    }
  }
}
