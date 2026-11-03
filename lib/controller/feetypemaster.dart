import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/fee_type_model.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/feetypemaster.dart';
import '../models/session_model.dart';      // ✅ ADD
import '../res/app_url.dart';               // ✅ ADD
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

class FeeTypeController extends GetxController {
  final TextEditingController feeTypeController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;

  final Rxn<FeeTypeMaster> feeTypeMaster = Rxn<FeeTypeMaster>();

  // ✅ CHANGE 1: hardcoded hatao, dynamic banao
  final RxString session = ''.obs;
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  String? schoolId;

  final String postUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/PostFeeTypeApp";
  final String viewBaseUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/ViewFeeTypeApp/";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    if (schoolId == null || schoolId!.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
      return;
    }

    // ✅ CHANGE 2: fetchSessionList pehle
    await fetchSessionList();
    await fetchFeeTypes();
  }

  // ✅ CHANGE 3: naya method
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

  @override
  void onClose() {
    feeTypeController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════
  // BAAKI SAB EXACT SAME — EK LINE NAHI BADI
  // ══════════════════════════════════════════

  Future<void> fetchFeeTypes() async {
    try {
      isLoading(true);

      final url = Uri.parse("$viewBaseUrl${Uri.encodeComponent(schoolId!)}");
      final res = await http.get(url, headers: {"Content-Type": "application/json"});

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(res.body);
        final parsed = FeeTypeMaster.fromJson(jsonMap);

        feeTypeMaster.value = parsed;

        final apiSession = parsed.currentSession?.toString().trim();
        if (apiSession != null && apiSession.isNotEmpty) {
          session.value = apiSession;
        }
      } else {
        AppSnackbar.apiError(
          "View API failed: ${res.statusCode} | ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addFeeType() async {
    final feeType = feeTypeController.text.trim();
    if (feeType.isEmpty) {
      AppSnackbar.error("Fee Type cannot be empty", title: "Validation");
      return;
    }

    try {
      isPosting(true);

      final url = Uri.parse(postUrl);

      final body = {
        "feeTypeId": 0,
        "feeType": feeType,
        "action": "1",
        "schoolId": schoolId,
        "session": session.value,
        "createBy": "",
        "updateBy": ""
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(res.body);
      final apiRes = ApiResponseModel.fromJson(jsonMap);

      if (apiRes.isSuccess == true) {
        AppSnackbar.success(apiRes.messages);
        feeTypeController.clear();
        await fetchFeeTypes();
      } else {
        // Server ka message technical hua to automatically "Something went wrong" ban jayega
        AppSnackbar.error(apiRes.messages, title: "Failed");
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  void openEditFeeTypeDialog(dynamic item) {
    final TextEditingController editCtrl =
    TextEditingController(text: item.feeType.toString());

    Get.defaultDialog(
      title: "Edit Fee Type",
      content: Column(
        children: [
          TextField(
            controller: editCtrl,
            decoration: const InputDecoration(
              hintText: "Enter Fee Type",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPosting.value
                    ? null
                    : () async {
                  final newName = editCtrl.text.trim();
                  if (newName.isEmpty) {
                    AppSnackbar.error("Fee Type cannot be empty",
                        title: "Validation");
                    return;
                  }
                  await updateFeeType(
                    feeTypeId: item.feeTypeId,
                    feeType: newName,
                  );
                },
                child: isPosting.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Update"),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> updateFeeType({
    required int feeTypeId,
    required String feeType,
  }) async {
    if (schoolId == null || schoolId!.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
      return;
    }

    try {
      isPosting(true);

      final url = Uri.parse(postUrl);

      final body = {
        "feeTypeId": feeTypeId,
        "feeType": feeType,
        "action": "2",
        "schoolId": schoolId,
        "session": session.value,
        "createBy": "",
        "updateBy": ""
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(res.body);
      final apiRes = ApiResponseModel.fromJson(jsonMap);

      if (apiRes.isSuccess == true) {
        Get.back();
        AppSnackbar.success(apiRes.messages);
        await fetchFeeTypes();
      } else {
        AppSnackbar.error(apiRes.messages, title: "Failed");
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  Future<void> toggleFeeTypeStatus(dynamic item) async {
    if (isPosting.value) return;

    String? storedSchoolId =
    await PrefManager().readValue(key: PrefConst.schollId);

    if (storedSchoolId == null || storedSchoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
      return;
    }

    try {
      isPosting(true);

      final String action = item.action == "1" ? "0" : "1";

      final url = Uri.parse(
        "https://playschool.edubloom.in/api/FeePaymentApp/ActiveandInactive?SchoolId=$storedSchoolId&fId=${item.feeTypeId}",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": action,
          "schoolId": storedSchoolId,
          "feeTypeId": item.feeTypeId,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        bool isUpdated = false;

        if (responseBody is List && responseBody.isNotEmpty) {
          isUpdated = responseBody[0]["action"].toString() == action;
        } else if (responseBody is Map<String, dynamic>) {
          isUpdated = responseBody["action"].toString() == action ||
              responseBody["isSuccess"] == true;
        }

        if (isUpdated) {
          await fetchFeeTypes();
          AppSnackbar.success(
            action == "1"
                ? "Fee Type Activated Successfully"
                : "Fee Type Inactivated Successfully",
          );
        } else {
          AppSnackbar.apiError(
            "Failed to toggle status | ${response.body}",
            statusCode: response.statusCode,
          );
        }
      } else {
        AppSnackbar.apiError(
          "Failed to communicate with the server | ${response.statusCode} | ${response.body}",
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }
}