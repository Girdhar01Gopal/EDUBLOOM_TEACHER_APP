import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/payment_master.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

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
      AppSnackbar.error("Please enter Payment Mode", title: "Validation");
      return;
    }
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
      return;
    }
    if (session.trim().isEmpty) {
      AppSnackbar.error("Session not found in storage");
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
          paymentModeController.clear();
          await fetchPaymentModes(showLoader: false);
          // ✅ Success snackbar list refresh ke baad, taaki list wala snackbar ise replace na kare
          AppSnackbar.success(msg.isEmpty ? "Payment Mode added" : msg);
        } else {
          // Server ka message technical hua to automatically "Something went wrong" ban jayega
          AppSnackbar.error(msg.isEmpty ? "Not saved" : msg, title: "Failed");
        }
      } else {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "API failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
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
      AppSnackbar.error("Payment Mode cannot be empty", title: "Validation");
      return;
    }
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
      return;
    }
    if (session.trim().isEmpty) {
      AppSnackbar.error("Session not found in storage");
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
          await fetchPaymentModes(showLoader: false);
          AppSnackbar.success(msg.isEmpty ? "Updated" : msg);
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
      isPosting(false);
    }
  }

  // ------------------------
  // GET: Fetch Payment Modes
  // ------------------------
  Future<void> fetchPaymentModes({bool showLoader = true}) async {
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
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
        AppSnackbar.apiError(
          "Fetch failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
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