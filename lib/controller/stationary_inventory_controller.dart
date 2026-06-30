import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';


import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/stationary_inventory_model.dart';
import '../models/session_model.dart';      // ✅ ADD
import '../res/app_url.dart';               // ✅ ADD

class StationaryInventoryController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxList<StationaryInventoryItem> inventoryList =
      <StationaryInventoryItem>[].obs;

  final RxList<StationaryInventoryItem> filteredList =
      <StationaryInventoryItem>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;
  final RxString searchText = ''.obs;

  final RxString schoolCode = ''.obs;

  // ✅ CHANGE 1: hardcoded String hatao, dynamic banao
  final RxString currentSession = ''.obs;
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  final String baseUrl =
      "https://playschool.edubloom.in/api/ProductApp/GetAllQuantityAsynsApp";

  @override
  void onInit() async {
    super.onInit();

    schoolCode.value = (await PrefManager().readValue(key: PrefConst.schollId))?.toString() ?? '';

    if (schoolCode.value.trim().isEmpty) {
      errorMsg.value =
      "SchoolId not found in storage. Login ke baad save nahi ho raha.";
      return;
    }


    await fetchSessionList();

    fetchInventoryData();
  }

  // ✅ CHANGE 3: naya method add karo
  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}${schoolCode.value}",
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
          currentSession.value = current;
        } else if (sessionList.isNotEmpty) {
          currentSession.value = sessionList.first;
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

  List<StationaryInventoryItem> get visibleList {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return filteredList;

    return filteredList.where((item) {
      return item.productName.toLowerCase().contains(q) ||
          item.totalQuantity.toString().contains(q) ||
          item.balanceQuantity.toString().contains(q) ||
          item.id.toString().contains(q);
    }).toList();
  }

  Future<void> fetchInventoryData() async {
    isLoading.value = true;
    errorMsg.value = '';
    inventoryList.clear();
    filteredList.clear();

    try {
      final uri = Uri.parse(
        "$baseUrl?schoolId=${Uri.encodeComponent(schoolCode.value)}&currentSession=${Uri.encodeComponent(currentSession.value)}",
      );

      final res = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) {
        errorMsg.value = "Failed (${res.statusCode})";
        Get.snackbar(
          "Error",
          "Failed (${res.statusCode})",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final StationaryInventoryModel model =
      stationaryInventoryModelFromJson(res.body);

      if (model.isSuccess != true) {
        errorMsg.value = model.messages ?? "No data found";
        return;
      }

      final List<StationaryInventoryItem> list = (model.data ?? [])
          .map(
            (e) => StationaryInventoryItem(
          id: e.productId ?? 0,
          productName: e.productName ?? '',
          totalQuantity: e.totalQuantity ?? 0,
          balanceQuantity: e.balanceQuantity ?? 0,
        ),
      )
          .toList();

      inventoryList.assignAll(list);
      filteredList.assignAll(list);
    } catch (e) {
      errorMsg.value = e.toString();

      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredList.assignAll(inventoryList);
      return;
    }

    filteredList.assignAll(
      inventoryList.where(
            (item) =>
        item.productName.toLowerCase().contains(query) ||
            item.totalQuantity.toString().contains(query) ||
            item.balanceQuantity.toString().contains(query) ||
            item.id.toString().contains(query),
      ),
    );
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = '';
    filteredList.assignAll(inventoryList);
  }

  Future<void> exportAndSharePdf() async {
    try {
      final list = visibleList;

      if (list.isEmpty) {
        Get.snackbar(
          "PDF",
          "No data available to export",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text(
              'Stationary Inventory Data',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              headers: const [
                'S.No',
                'Product',
                'Total Quantity',
                'Balance Quantity',
              ],
              data: List.generate(
                list.length,
                    (index) => [
                  '${index + 1}',
                  list[index].productName,
                  '${list[index].totalQuantity}',
                  '${list[index].balanceQuantity}',
                ],
              ),
            ),
          ],
        ),
      );

      final Directory dir = await getTemporaryDirectory();
      final String path = '${dir.path}/stationary_inventory.pdf';
      final File file = File(path);

      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Stationary Inventory PDF',
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate/share PDF",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class StationaryInventoryItem {
  final int id;
  final String productName;
  final int totalQuantity;
  final int balanceQuantity;

  StationaryInventoryItem({
    required this.id,
    required this.productName,
    required this.totalQuantity,
    required this.balanceQuantity,
  });
}