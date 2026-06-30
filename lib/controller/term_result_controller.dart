import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart';
import '../models/terms_result_model.dart';
import '../res/app_url.dart';

class TermResultController extends GetxController {
  final TextEditingController termController = TextEditingController();

  final RxBool isPosting = false.obs;
  final RxBool isListLoading = false.obs;

  final RxList<TermData> termList = <TermData>[].obs;
  final RxList<TermData> filteredList = <TermData>[].obs;

  String schoolId = "";
  String token = "";
  String session = ""; // ✅ NEW

  // ✅ GET — now includes session in URL
  String get _viewUrl =>
      '${AppUrl.base_url}api/Result/ViewTerm/$schoolId/$session';

  String get _postUrl => '${AppUrl.base_url}api/Result/PostAddTerm';

  Map<String, String> get _headers {
    final Map<String, String> h = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    if (token.trim().isNotEmpty) {
      h["Authorization"] = "Bearer $token";
    }
    return h;
  }

  dynamic _safeDecodeResponse(http.Response res, {required String label}) {
    final String ct = (res.headers['content-type'] ?? '').toLowerCase();
    final String body = res.body;
    final String preview =
    body.substring(0, body.length > 300 ? 300 : body.length);

    debugPrint("[$label] URL: ${res.request?.url}");
    debugPrint("[$label] STATUS: ${res.statusCode}");
    debugPrint("[$label] CONTENT-TYPE: $ct");
    debugPrint("[$label] BODY(300): $preview");

    if (preview.toLowerCase().contains("<!doctype html") ||
        ct.contains("text/html")) {
      throw Exception("[$label] Server returned HTML instead of JSON.");
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("[$label] HTTP ${res.statusCode} - ${res.body}");
    }

    if (body.trim().isEmpty) return <String, dynamic>{};

    return jsonDecode(body);
  }

  // =========================
  // INIT
  // =========================
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    // ✅ Session pehle, phir list
    await _fetchCurrentSession();
    await fetchTerms();
  }

  @override
  void onClose() {
    termController.dispose();
    super.onClose();
  }

  // =========================
  // SESSION FETCH
  // =========================
  Future<void> _fetchCurrentSession() async {
    try {
      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.view_session}$schoolId',
      );
      final res = await http.get(url, headers: _headers);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final sessionModel = SessionModel.fromJson(decoded);
        session =
            sessionModel.currentSession?.session?.toString().trim() ?? "";
        debugPrint("Current Session: $session");
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    }
  }

  // =========================
  // GET: Fetch Terms
  // ✅ URL: ViewTerm/$schoolId/$session
  // =========================
  Future<void> fetchTerms() async {
    try {
      isListLoading(true);

      if (session.trim().isEmpty) await _fetchCurrentSession();

      final http.Response response = await http.get(
        Uri.parse(_viewUrl),
        headers: _headers,
      );

      final dynamic decoded =
      _safeDecodeResponse(response, label: "ViewTerm");

      final TermsResultModel parsed =
      TermsResultModel.fromJson(decoded as Map<String, dynamic>);

      termList.assignAll(parsed.listData ?? <TermData>[]);
      filteredList.assignAll(parsed.listData ?? <TermData>[]);
    } catch (e) {
      termList.clear();
      filteredList.clear();
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // Search
  // =========================
  void searchTerm(String value) {
    final String search = value.trim().toLowerCase();
    if (search.isEmpty) {
      filteredList.assignAll(termList);
      return;
    }
    filteredList.assignAll(
      termList
          .where((item) =>
          (item.term ?? "").toLowerCase().contains(search))
          .toList(),
    );
  }

  // =========================
  // POST: Add Term
  // ✅ Body now includes session
  // =========================
  Future<void> addTerm() async {
    final String text = termController.text.trim();

    if (text.isEmpty) {
      Get.snackbar("Validation", "Term cannot be empty");
      return;
    }

    final bool alreadyExists = termList.any(
          (e) => (e.term ?? "").trim().toLowerCase() == text.toLowerCase(),
    );

    if (alreadyExists) {
      Get.snackbar("Warning", "This term already exists");
      return;
    }

    try {
      isPosting(true);

      final Map<String, dynamic> requestBody = {
        "id": 0,
        "term": text,
        "action": "1",
        "createDate": DateTime.now().toIso8601String(),
        "updateDate": DateTime.now().toIso8601String(),
        "createBy": "admin",
        "updateBy": "admin",
        "schoolId": schoolId,
        "session": session, // ✅ NEW
      };

      debugPrint("ADD TERM URL => $_postUrl");
      debugPrint("ADD TERM BODY => ${jsonEncode(requestBody)}");

      final http.Response response = await http.post(
        Uri.parse(_postUrl),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      final dynamic decoded =
      _safeDecodeResponse(response, label: "PostAddTerm");

      final Map<String, dynamic> responseMap =
      decoded as Map<String, dynamic>;
      final bool isSuccess = responseMap["isSuccess"] == true;
      final String message =
          responseMap["messages"]?.toString() ?? "Term saved successfully.";

      if (isSuccess) {
        termController.clear();
        await fetchTerms();
        Get.snackbar("Success", message);
      } else {
        Get.snackbar("Error", message);
      }
    } catch (e) {
      Get.snackbar("Error", "Add failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // =========================
  // Edit Dialog
  // =========================
  void openEditTermDialog(TermData item) {
    final TextEditingController editController =
    TextEditingController(text: item.term ?? "");

    Get.defaultDialog(
      title: "Edit Term Result",
      radius: 8,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Enter Term",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPosting.value
                  ? null
                  : () async {
                final String updatedText =
                editController.text.trim();
                if (updatedText.isEmpty) {
                  Get.snackbar(
                      "Validation", "Term cannot be empty");
                  return;
                }
                await updateTerm(item, updatedText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              child: isPosting.value
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Update",
                  style: TextStyle(color: Colors.white)),
            ),
          )),
        ],
      ),
    );
  }

  // =========================
  // POST: Update Term
  // ✅ Body now includes session
  // =========================
  Future<void> updateTerm(TermData item, String updatedText) async {
    final bool alreadyExists = termList.any(
          (e) =>
      e.id != item.id &&
          (e.term ?? "").trim().toLowerCase() ==
              updatedText.toLowerCase(),
    );

    if (alreadyExists) {
      Get.snackbar("Warning", "This term already exists");
      return;
    }

    try {
      isPosting(true);

      final Map<String, dynamic> requestBody = {
        "id": item.id ?? 0,
        "term": updatedText,
        "action": item.action ?? "1",
        "createDate":
        (item.createDate ?? DateTime.now()).toIso8601String(),
        "updateDate": DateTime.now().toIso8601String(),
        "createBy": item.createBy ?? "admin",
        "updateBy": "admin",
        "schoolId": item.schoolId ?? schoolId,
        "session": item.session?.isNotEmpty == true
            ? item.session
            : session, // ✅ NEW
      };

      debugPrint("UPDATE TERM URL => $_postUrl");
      debugPrint("UPDATE TERM BODY => ${jsonEncode(requestBody)}");

      final http.Response response = await http.post(
        Uri.parse(_postUrl),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      final dynamic decoded =
      _safeDecodeResponse(response, label: "UpdateTerm");

      final Map<String, dynamic> responseMap =
      decoded as Map<String, dynamic>;
      final bool isSuccess = responseMap["isSuccess"] == true;
      final String message = responseMap["messages"]?.toString() ??
          "Term updated successfully.";

      if (isSuccess) {
        Get.back();
        await fetchTerms();
        Get.snackbar("Success", message);
      } else {
        Get.snackbar("Error", message);
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // =========================
  // Refresh
  // =========================
  Future<void> refreshList() async {
    await _fetchCurrentSession();
    await fetchTerms();
  }
}