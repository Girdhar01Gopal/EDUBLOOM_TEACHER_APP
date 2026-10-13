import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/ClassWiseFeeStructureModel.dart';

class ClassWiseFeeStructureController extends GetxController {
  RxBool isLoading = false.obs;

  var schoolCode = "".obs;
  final session = "".obs;

  // search state
  final isSearching = false.obs;
  final searchQuery = "".obs;
  final searchTextController = TextEditingController();

  RxList<FeeData> raw = <FeeData>[].obs;
  RxList<FeeStructureTableRow> tableRows = <FeeStructureTableRow>[].obs;

  // NEW: har table row ke saath classId (sirf class ki pehli row par value, baaki null)
  // isse per-class share icon pata chalta hai
  RxList<int?> rowClassIds = <int?>[].obs;

  // class name se filtered data
  List<FeeData> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return List<FeeData>.from(raw);
    return raw
        .where((e) => e.classBatchText.toLowerCase().contains(q))
        .toList();
  }

  // filtered data ka total
  int get grandTotal => filtered.fold(0, (s, e) => s + e.amountAsInt);

  String get apiUrl =>
      "https://playschool.edubloom.in/api/ReportApp/GetFeeStructureAppAsync/${Uri.encodeComponent(schoolCode.value)}/${session.value}";

  void _buildTable() {
    final list = filtered;

    list.sort((a, b) {
      final c = a.classId.compareTo(b.classId);
      if (c != 0) return c;
      final t = a.feeTypeText.compareTo(b.feeTypeText);
      if (t != 0) return t;
      return a.durationText.compareTo(b.durationText);
    });

    final rows = <FeeStructureTableRow>[];
    final ids = <int?>[];
    int snoCounter = 0;
    int? lastClassId;

    for (final item in list) {
      final isFirst = item.classId != lastClassId;
      if (isFirst) snoCounter++;

      final amt = item.amountAsInt == 0 ? "" : item.amountAsInt.toString();

      rows.add(
        FeeStructureTableRow(
          sno: isFirst ? snoCounter.toString() : "",
          classBatch: isFirst ? item.classBatchText : "",
          feeType: item.feeTypeText,
          feeDuration: item.durationText,
          amount: amt,
        ),
      );
      ids.add(isFirst ? item.classId : null);

      lastClassId = item.classId;
    }

    // pehle ids, phir rows (taaki UI rebuild par dono sync rahein)
    rowClassIds.assignAll(ids);
    tableRows.assignAll(rows);
  }

  // search open/close
  void toggleSearch() {
    if (isSearching.value) {
      isSearching.value = false;
      searchTextController.clear();
      searchQuery.value = "";
    } else {
      isSearching.value = true;
    }
  }

  // NEW: share text banane ka common function
  String _buildShareText(List<FeeData> source) {
    final list = List<FeeData>.from(source);

    list.sort((a, b) {
      final c = a.classId.compareTo(b.classId);
      if (c != 0) return c;
      final t = a.feeTypeText.compareTo(b.feeTypeText);
      if (t != 0) return t;
      return a.durationText.compareTo(b.durationText);
    });

    final sb = StringBuffer();
    sb.writeln("Class Wise Fee Structure");
    sb.writeln("Session: ${session.value}");
    sb.writeln("");

    int? lastClassId;
    int classTotal = 0;
    int total = 0;
    final classIds = <int>{};

    void writeClassTotal() {
      if (lastClassId != null) {
        sb.writeln("Total: $classTotal");
        sb.writeln("");
      }
    }

    for (final item in list) {
      if (item.classId != lastClassId) {
        writeClassTotal();
        classTotal = 0;
        sb.writeln("Class: ${item.classBatchText}");
        classIds.add(item.classId);
      }
      sb.writeln(
          "- ${item.feeTypeText} (${item.durationText}): ${item.amountAsInt}");
      classTotal += item.amountAsInt;
      total += item.amountAsInt;
      lastClassId = item.classId;
    }
    writeClassTotal();

    // Grand Total sirf tab jab ek se zyada class ho
    if (classIds.length > 1) {
      sb.writeln("Grand Total: $total");
    }

    return sb.toString();
  }

  // NEW: AppBar share -> complete data (saari classes), search filter ignore
  Future<void> shareAllFeeStructure() async {
    if (raw.isEmpty) {
      Get.snackbar(
        "Error",
        "No data to share",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    await Share.share(
      _buildShareText(raw),
      subject: "Class Wise Fee Structure",
    );
  }

  // NEW: list ke andar share -> sirf ek particular class
  Future<void> shareClassFeeStructure(int classId) async {
    final list = raw.where((e) => e.classId == classId).toList();

    if (list.isEmpty) {
      Get.snackbar(
        "Error",
        "No data to share",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    await Share.share(
      _buildShareText(list),
      subject: "Fee Structure - ${list.first.classBatchText}",
    );
  }

  Future<void> fetchFeeStructure() async {
    if (session.value.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Session not available",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;
    raw.clear();
    rowClassIds.clear();
    tableRows.clear();

    try {
      final res = await http.get(
        Uri.parse(apiUrl),
        headers: const {"Accept": "application/json"},
      );

      if (res.statusCode != 200) {
        Get.snackbar(
          "Error",
          "Failed (${res.statusCode})",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        Get.snackbar(
          "Error",
          "Invalid response format",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final obj = FeeResponse.fromJson(decoded);

      if (!obj.isSuccess) {
        Get.snackbar(
          "Error",
          obj.messages ?? "API returned isSuccess=false",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      raw.assignAll(obj.data);
      _buildTable();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => _buildTable());
    _initializeData();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> _initializeData() async {
    schoolCode.value =
        await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    try {
      final res = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/${schoolCode.value}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        session.value =
            jsonData['currentSession']?['currentSession']?.toString() ?? "";
      } else {
        Get.snackbar("Error", "Session fetch failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Session fetch failed: $e");
    }
  }
}