import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../utils/app_snackbar.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final oldPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final showOld = false.obs;
  final showNew = false.obs;
  final showConfirm = false.obs;

  final isLoading = false.obs;

  // ✅ For debug text in screen
  final sclInfoId = "".obs;
  final role = "".obs;

  // Strength meter
  final strengthScore = 0.0.obs;
  final strengthLabel = "Weak".obs;

  var schoolId = "".obs;
  var roleName = "";

  late final Dio _dio;

  static const String _url =
      "https://playschool.edubloom.in/api/MasterApp/ChangePassword";

  @override
  void onInit() {
    super.onInit();
    _loadSessionFromPrefs();

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // ✅ Load once from PrefManager (your existing system)


    _computeStrength("");
  }

  void _loadSessionFromPrefs() async{
    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? ""
        .toString()
        .trim();




  }

  @override
  void onClose() {
    oldPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  void toggleOld() => showOld.value = !showOld.value;
  void toggleNew() => showNew.value = !showNew.value;
  void toggleConfirm() => showConfirm.value = !showConfirm.value;

  void onNewPasswordChanged(String v) => _computeStrength(v);

  // ---------------- VALIDATIONS ----------------
  String? validateOld(String? v) {
    if (v == null || v.trim().isEmpty) return "Current password is required";
    if (v.trim().length < 4) return "Current password looks too short";
    return null;
  }

  String? validateNew(String? v) {
    if (v == null || v.trim().isEmpty) return "New password is required";
    if (v.trim().length < 6) return "Minimum 6 characters required";
    return null;
  }

  String? validateConfirm(String? v) {
    if (v == null || v.trim().isEmpty) return "Confirm password is required";
    if (v.trim() != newPasswordCtrl.text.trim()) return "Passwords do not match";
    return null;
  }



  Future<void> changePassword() async {
    // Session check
    if (schoolId.value.trim().isEmpty) {
      AppSnackbar.error(
        "School ID missing. Please login again.",
        title: "Session Expired",
      );
      Get.offAllNamed(RouteName.login_screen);
      return;
    }

    // Input validation
    final oldPwd = oldPasswordCtrl.text.trim();
    final newPwd = newPasswordCtrl.text.trim();
    final confirmPwd = confirmPasswordCtrl.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      AppSnackbar.error("All fields are required.");
      return;
    }

    if (newPwd != confirmPwd) {
      AppSnackbar.error("New password and confirm password do not match.");
      return;
    }

    if (oldPwd == newPwd) {
      AppSnackbar.error("New password must be different from old password.");
      return;
    }

    isLoading(true);

    try {
      final payload = {
        "oldPassword": oldPwd,
        "newPassword": newPwd,
        "confirmPassword": confirmPwd,
        "sclInfoId": schoolId.value.trim(),
        "role": "Admin",
      };

      final response = await https.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data =
      jsonDecode(response.body.isNotEmpty ? response.body : "{}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Fixed success text (server text is never shown directly)
        AppSnackbar.success("Password changed successfully.");

        await logoutAndRedirect();
      } else {
        // Server's own short message (e.g. "Old password is incorrect") is
        // shown only if it is clean; technical / long text becomes
        // "Something went wrong" automatically inside AppSnackbar.error().
        AppSnackbar.error(
          data["message"]?.toString() ?? "Failed to change password",
        );
      }
    } catch (e, s) {
      // Net off / timeout / bad response -> user sees "Something went wrong",
      // real error (with url) prints only in the console.
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }

  String _dioMsg(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data["message"] != null) return data["message"].toString();
      return "Request failed (HTTP ${e.response?.statusCode}).";
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timeout. Try again.";
      case DioExceptionType.connectionError:
        return "No internet / server unreachable.";
      default:
        return "Something went wrong. Try again.";
    }
  }

  Future<void> logoutAndRedirect() async {
    // minimal logout (since you said no changes)
    PrefManager().writeValue(key: PrefConst.isLoggedIn, value: "No");
    // optional:
    // PrefManager().writeValue(key: PrefConst.token, value: "");

    Get.offAllNamed(RouteName.login_screen);
  }

  // ---------------- STRENGTH METER ----------------
  void _computeStrength(String pwd) {
    final p = pwd;

    double score = 0.0;
    if (p.length >= 8) score += 0.25;
    if (p.length >= 12) score += 0.10;

    final hasLower = RegExp(r'[a-z]').hasMatch(p);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(p);
    final hasDigit = RegExp(r'\d').hasMatch(p);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(p);

    if (hasLower) score += 0.15;
    if (hasUpper) score += 0.15;
    if (hasDigit) score += 0.15;
    if (hasSpecial) score += 0.20;

    score = score.clamp(0.0, 1.0);

    strengthScore.value = score;
    strengthLabel.value =
    (score < 0.35) ? "Weak" : (score < 0.7) ? "Medium" : "Strong";
  }
}