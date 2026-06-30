import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/payment_master.dart';

class PaymentMasterController extends GetxController {
  final TextEditingController paymentModeController = TextEditingController();

  final isPosting = false.obs;
  final isLoading = false.obs;

  final paymentModes = <PaymentMode>[].obs;
  final searchText = "".obs;

  String schoolId = "";
  String session = "";

  final String postUrl =
      "https://playschool.edubloom.in/api/MasterApp/PostPaymentModeApp";

  final String getBaseUrl =
      "https://playschool.edubloom.in/api/DaycareFeePaymentApp/ViewPaymentModeApp/";

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    await fetchPaymentModes();
  }

  @override
  void onClose() {
    paymentModeController.dispose();
    super.onClose();
  }

  // ------------------------
  // POST: Add Payment Mode
  // ------------------------
  Future<void> savePaymentMode() async {
    final mode = paymentModeController.text.trim();

    if (mode.isEmpty) {
      Get.snackbar("Validation", "Please enter Payment Mode");
      return;
    }
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }
    if (session.trim().isEmpty) {
      Get.snackbar("Error", "Session not found in storage");
      return;
    }

    final body = {
      "paymentModeID": 0,
      "paymentMode": mode,
      "action": "1",
      "schoolId": schoolId,
      "session": session,
      "createBy": "Admin",
      "updateBy": "string",
    };

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonRes = jsonDecode(res.body);
        final msg = (jsonRes["messages"] ?? "").toString();
        final data = (jsonRes["data"] ?? "").toString();

        final ok = data.toUpperCase() == "SUCCESS" ||
            msg.toLowerCase().contains("success");

        if (ok) {
          Get.snackbar("Success", msg.isEmpty ? "Payment Mode added" : msg);
          paymentModeController.clear();
          await fetchPaymentModes(showLoader: false);
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Not saved" : msg);
        }
      } else {
        Get.snackbar("Error", "API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Save failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // ------------------------
  // POST: Update Payment Mode
  // ------------------------
  Future<void> updatePaymentMode({
    required int paymentModeId,
    required String paymentMode,
  }) async {
    final mode = paymentMode.trim();

    if (mode.isEmpty) {
      Get.snackbar("Validation", "Payment Mode cannot be empty");
      return;
    }
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }
    if (session.trim().isEmpty) {
      Get.snackbar("Error", "Session not found in storage");
      return;
    }

    final body = {
      "paymentModeID": paymentModeId,
      "paymentMode": mode,
      "action": "2", // ✅ update
      "schoolId": schoolId,
      "session": session,
      "createBy": "Admin",
      "updateBy": "Admin",
    };

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonRes = jsonDecode(res.body);
        final msg = (jsonRes["messages"] ?? "").toString();
        final data = (jsonRes["data"] ?? "").toString();

        final ok = data.toUpperCase() == "SUCCESS" ||
            msg.toLowerCase().contains("success");

        if (ok) {
          Get.back(); // close dialog
          Get.snackbar("Success", msg.isEmpty ? "Updated" : msg);
          await fetchPaymentModes(showLoader: false);
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Update failed" : msg);
        }
      } else {
        Get.snackbar("Error", "Update API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // ------------------------
  // GET: Fetch Payment Modes
  // ------------------------
  Future<void> fetchPaymentModes({bool showLoader = true}) async {
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    final url = "$getBaseUrl$schoolId";

    try {
      if (showLoader) isLoading(true);

      final res = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        final pm = PaymentMaster.fromJson(jsonRes);
        paymentModes.assignAll(pm.listData);
      } else {
        Get.snackbar("Error", "Fetch failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch failed: $e");
    } finally {
      if (showLoader) isLoading(false);
    }
  }

  // filtered list
  List<PaymentMode> get filteredList {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return paymentModes;

    return paymentModes.where((e) {
      return e.paymentMode.toLowerCase().contains(q) ||
          e.paymentModeId.toString().contains(q);
    }).toList();
  }
}
