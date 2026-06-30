import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/reportcardinside1.dart';
import '../models/reportcardinside2.dart';
import '../models/reportcardinside3.dart';
import '../models/reportcardinside4.dart';
import '../res/app_url.dart';

class ReportCardDetailController extends GetxController {
  int studentId = 0;
  int classId   = 0;
  String schoolId = '';
  String session  = '';
  String token    = '';
  String term     = '';

  final isLoading     = true.obs;
  final selectedTheme = 0.obs;

  final Rx<ReportCard1Model?>          schoolInfo      = Rx(null);
  final Rx<ReportCardInside2Model?>    studentInfo     = Rx(null);
  final RxList<ReportCardInside3Model> skillsList      = <ReportCardInside3Model>[].obs;
  final RxList<ReportCardInside4Model> descriptorsList = <ReportCardInside4Model>[].obs;

  final GlobalKey repaintKey = GlobalKey();

  // onInit mein kuch mat karo — screen ke initState se init() call hoga
  @override
  void onInit() {
    super.onInit();
    // intentionally empty
  }

  // ── Called from screen initState + RefreshIndicator onRefresh ──
  Future<void> init() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    token    = await PrefManager().readValue(key: PrefConst.token)    ?? '';

    debugPrint("DetailController.init() => "
        "studentId:$studentId classId:$classId "
        "schoolId:$schoolId session:$session term:$term");

    if (studentId == 0 || classId == 0 || schoolId.isEmpty) {
      isLoading(false);
      _showSnack("Error", "Invalid data. Please try again.");
      return;
    }

    await _loadAll();
  }

  Map<String, String> get _headers => {
    "Accept"       : "application/json",
    "Content-Type" : "application/json",
    if (token.trim().isNotEmpty) "Authorization": "Bearer $token",
  };

  Future<void> _loadAll() async {
    try {
      isLoading(true);
      await Future.wait([
        _fetchSchoolInfo(),
        _fetchStudentDetails(),
        _fetchSkillsDetails(),
        _fetchDescriptorsDetails(),
      ]);
    } catch (e) {
      debugPrint("loadAll error: $e");
      _showSnack("Error", "Failed to load report card: $e");
    } finally {
      isLoading(false);
    }
  }

  // API 1: GET /api/Result/GetSMSDetails/{schoolId}
  Future<void> _fetchSchoolInfo() async {
    try {
      final url = '${AppUrl.base_url}api/Result/GetSMSDetails/$schoolId';
      debugPrint("API1 => $url");
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("API1 status: ${res.statusCode}");
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          schoolInfo.value = ReportCard1Model.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty) {
          schoolInfo.value = ReportCard1Model.fromJson(
              decoded.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint("fetchSchoolInfo error: $e");
    }
  }

  // API 2: GET /api/Result/GetStudentDetails/{studentId}
  Future<void> _fetchStudentDetails() async {
    try {
      final url =
          '${AppUrl.base_url}api/Result/GetStudentDetails/$studentId';
      debugPrint("API2 => $url");
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("API2 status: ${res.statusCode}");
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          studentInfo.value = ReportCardInside2Model.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty) {
          studentInfo.value = ReportCardInside2Model.fromJson(
              decoded.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint("fetchStudentDetails error: $e");
    }
  }

  // API 3: GET /api/Result/GetSkillsDetails/{classId}/{schoolId}/{session}
  Future<void> _fetchSkillsDetails() async {
    try {
      final encodedSession = Uri.encodeComponent(session);
      final url =
          '${AppUrl.base_url}api/Result/GetSkillsDetails/$classId/$schoolId/$encodedSession';
      debugPrint("API3 => $url");
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("API3 status: ${res.statusCode}");
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        final decoded = jsonDecode(res.body);
        List<dynamic> list = decoded is List
            ? decoded
            : (decoded['listData'] ?? decoded['data'] ?? []) as List<dynamic>;
        skillsList.assignAll(list
            .map((e) =>
            ReportCardInside3Model.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (e) {
      debugPrint("fetchSkillsDetails error: $e");
    }
  }

  // API 4: GET /api/Result/GetDescriptorsDetails/{classId}/{studentId}
  Future<void> _fetchDescriptorsDetails() async {
    try {
      final url =
          '${AppUrl.base_url}api/Result/GetDescriptorsDetails/$classId/$studentId';
      debugPrint("API4 => $url");
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("API4 status: ${res.statusCode}");
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        final decoded = jsonDecode(res.body);
        List<dynamic> list = decoded is List
            ? decoded
            : (decoded['listData'] ?? decoded['data'] ?? []) as List<dynamic>;
        descriptorsList.assignAll(list
            .map((e) =>
            ReportCardInside4Model.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (e) {
      debugPrint("fetchDescriptorsDetails error: $e");
    }
  }

  // ── Capture RepaintBoundary as PNG bytes ─────────────────────
  Future<Uint8List?> _captureWidget() async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image    = await boundary.toImage(pixelRatio: 2.5);
      final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("captureWidget error: $e");
      return null;
    }
  }

  // ── Print ────────────────────────────────────────────────────
  Future<void> printReportCard() async {
    try {
      _showSnack("Please wait", "Preparing print...",
          bg: Colors.blue.shade600);
      final imgBytes = await _captureWidget();
      if (imgBytes == null) {
        _showSnack("Error", "Could not capture report card.");
        return;
      }
      final doc      = pw.Document();
      final pdfImage = pw.MemoryImage(imgBytes);
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) =>
            pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain)),
      ));
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name:
        'ReportCard_${studentInfo.value?.studentName ?? studentId}.pdf',
      );
    } catch (e) {
      _showSnack("Error", "Print failed: $e");
    }
  }

  // ── Share as PDF ─────────────────────────────────────────────
  Future<void> shareReportCard() async {
    try {
      _showSnack("Please wait", "Preparing share...",
          bg: Colors.blue.shade600);
      final imgBytes = await _captureWidget();
      if (imgBytes == null) {
        _showSnack("Error", "Could not capture report card.");
        return;
      }

      // Wrap captured image inside a proper PDF page
      final doc      = pw.Document();
      final pdfImage = pw.MemoryImage(imgBytes);
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) =>
            pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain)),
      ));
      final pdfBytes = await doc.save();

      final dir  = await getTemporaryDirectory();
      final name = studentInfo.value?.studentName ?? 'student';
      final file =
      File('${dir.path}/report_card_$name.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text   : 'Report Card - $name | ${schoolInfo.value?.schoolName ?? ""}',
        subject: 'Report Card',
      );
    } catch (e) {
      _showSnack("Error", "Share failed: $e");
    }
  }

  void _showSnack(String title, String message,
      {Color bg = Colors.red, Color textColor = Colors.white}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      colorText: textColor,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
    );
  }
}