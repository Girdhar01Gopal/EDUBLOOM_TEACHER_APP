import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/add_route_model.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

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
      AppSnackbar.error("SchoolId not found in storage");
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
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "GetRoute API failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addRoute() async {
    final routeNoText = routeNoController.text.trim();
    final busNo = busNoController.text.trim();

    if (routeNoText.isEmpty) {
      AppSnackbar.error("Route No is required", title: "Validation");
      return;
    }
    final routeNo = int.tryParse(routeNoText);
    if (routeNo == null || routeNo <= 0) {
      AppSnackbar.error("Enter a valid Route No", title: "Validation");
      return;
    }
    if (busNo.isEmpty) {
      AppSnackbar.error("Bus No is required", title: "Validation");
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
          AppSnackbar.success(msg.isEmpty ? "Route added" : msg);
          routeNoController.clear();
          busNoController.clear();
          await fetchRoutes();
        } else {
          // Server ka message technical hua to automatically "Something went wrong" ban jayega
          AppSnackbar.error(msg.isEmpty ? "Route add failed" : msg, title: "Failed");
        }
      } else {
        AppSnackbar.apiError(
          "PostRoute API failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
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
      AppSnackbar.error("Enter a valid Route No", title: "Validation");
      return;
    }
    if (busNo.isEmpty) {
      AppSnackbar.error("Bus No is required", title: "Validation");
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
          AppSnackbar.success(msg.isEmpty ? "Route updated" : msg);
          await fetchRoutes();
        } else {
          AppSnackbar.error(msg.isEmpty ? "Update failed" : msg, title: "Failed");
        }
      } else {
        AppSnackbar.apiError(
          "Update API failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isUpdating(false);
    }
  }
}