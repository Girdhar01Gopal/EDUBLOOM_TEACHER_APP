// ── File: controller/student_wise_yearly_report_controller.dart ────────────

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart';
import '../models/student_fee_report_yearly_model.dart';
import '../res/app_url.dart';

class StudentWiseYearlyReportController extends GetxController {
  // ── State ───────────────────────────────────────────────────────────────
  RxList<YearlyReportModel> reportList = <YearlyReportModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSessionLoading = false.obs;
  RxBool isSearched = false.obs;
  RxBool isPdfGenerating = false.obs; // ← PDF generation loader
  RxString errorMessage = ''.obs;

  // ── Session ─────────────────────────────────────────────────────────────
  final sessionData = SessionModel().obs;
  var selectedSession = Rx<sListDdata?>(null);
  RxList<sListDdata> sessionList = <sListDdata>[].obs;

  // ── Local stored values ──────────────────────────────────────────────────
  var schoolId = ''.obs;
  var currentSession = ''.obs;

  // ── Summary getters ──────────────────────────────────────────────────────
  int get totalStudents => reportList.length;
  double get sumTotalFee =>
      reportList.fold(0.0, (s, e) => s + e.totalFee);
  double get sumTotalDiscount =>
      reportList.fold(0.0, (s, e) => s + e.totalDiscount);
  double get sumNetFee =>
      reportList.fold(0.0, (s, e) => s + e.netFee);
  double get sumTotalPaid =>
      reportList.fold(0.0, (s, e) => s + e.totalPaid);
  double get sumTotalDue =>
      reportList.fold(0.0, (s, e) => s + e.totalDue);

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() async {
    schoolId.value =
        await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    currentSession.value =
        await PrefManager().readValue(key: PrefConst.session) ?? '';
    debugPrint('SchoolId: ${schoolId.value}');
    debugPrint('Session: ${currentSession.value}');
    await fetchSessionData();
    super.onInit();
  }

  // ── Fetch sessions ───────────────────────────────────────────────────────
  Future<void> fetchSessionData() async {
    try {
      isSessionLoading.value = true;

      final url = Uri.parse(
          '${AppUrl.base_url}${AppUrl.view_session}${schoolId.value}');
      debugPrint('Session URL: $url');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      debugPrint('Session status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        sessionData.value = SessionModel.fromJson(data);

        if (sessionData.value.listData != null &&
            sessionData.value.listData!.isNotEmpty) {
          sessionList.assignAll(sessionData.value.listData!);

          if (sessionData.value.currentSession != null) {
            selectedSession.value = sessionList.firstWhereOrNull(
                  (s) =>
              s.sessionId ==
                  sessionData.value.currentSession!.sessionId,
            );
          }
          selectedSession.value ??= sessionList.first;
        }
      }
    } catch (e) {
      debugPrint('Session fetch error: $e');
    } finally {
      isSessionLoading.value = false;
    }
  }

  void onSessionChanged(sListDdata? value) {
    if (value != null) {
      selectedSession.value = value;
      reportList.clear();
      isSearched.value = false;
      errorMessage.value = '';
    }
  }

  // ── Fetch yearly report ──────────────────────────────────────────────────
  Future<void> search() async {
    if (selectedSession.value == null) {
      Get.snackbar('Error', 'Please select a session',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      reportList.clear();
      isSearched.value = false;

      final String sessionName =
      (selectedSession.value!.session ?? '').trim();
      final String sid = schoolId.value.trim();
      final String base = AppUrl.base_url.endsWith('/')
          ? AppUrl.base_url
          : '${AppUrl.base_url}/';
      final String fullUrl =
          '${base}api/ReportApp/StudentWiseYearlyReportApp/$sid/$sessionName';

      debugPrint('Report URL: $fullUrl');

      final response = await http
          .get(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 20));

      debugPrint('Status: ${response.statusCode}');
      final int previewLen = response.body.length.clamp(0, 400);
      debugPrint('Body preview: ${response.body.substring(0, previewLen)}');

      if (response.statusCode == 200) {
        final String body = response.body.trim();

        if (body.isEmpty || body == 'null' || body == '[]') {
          errorMessage.value = 'No records found for the selected session.';
          isSearched.value = true;
          return;
        }

        final dynamic decoded = jsonDecode(body);
        List<dynamic> rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map) {
          for (final key in ['data', 'Data', 'result', 'Result', 'list']) {
            if (decoded.containsKey(key) && decoded[key] is List) {
              rawList = decoded[key] as List;
              break;
            }
          }
        }

        if (rawList.isEmpty) {
          errorMessage.value = 'No records found for selected session.';
          isSearched.value = true;
          return;
        }

        reportList.assignAll(
          rawList.asMap().entries.map((e) =>
              YearlyReportModel.fromJson(
                  e.value as Map<String, dynamic>, e.key)),
        );
        isSearched.value = true;
      } else {
        errorMessage.value =
        'Server returned ${response.statusCode}. Please try again.';
        isSearched.value = true;
      }
    } on FormatException catch (e) {
      debugPrint('JSON parse error: $e');
      errorMessage.value = 'Invalid response format from server.';
      isSearched.value = true;
    } catch (e) {
      debugPrint('Report fetch error TYPE: ${e.runtimeType}');
      debugPrint('Report fetch error: $e');
      errorMessage.value = 'Error: $e';
      isSearched.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // ── PDF Generation ────────────────────────────────────────────────────────

  /// Generates PDF bytes from current reportList
  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();

    // ── Helper: Indian number format ─────────────────────────────────────
    String fmtAmt(double v) {
      final String raw = v.toStringAsFixed(0);
      if (raw.length <= 3) return raw;
      final String last3 = raw.substring(raw.length - 3);
      final String rest = raw.substring(0, raw.length - 3);
      final StringBuffer buf = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
        buf.write(rest[i]);
      }
      return 'Rs. ${buf.toString()},$last3';
    }

    final String sessionLabel = selectedSession.value?.session ?? '';

    // ── Header style ─────────────────────────────────────────────────────
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 7,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(fontSize: 7, color: PdfColors.black);
    final totalStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 7,
      color: PdfColors.white,
    );

    // ── Table columns ─────────────────────────────────────────────────────
    final headers = [
      'S.No', 'Reg. No', 'Student Name', 'Father Name',
      'Class', 'Section', 'Total Fee', 'Discount', 'Net Fee', 'Paid', 'Due',
    ];

    // Column flex widths (relative)
    final colWidths = [
      0.4, 0.7, 1.2, 1.2, 0.7, 0.6, 0.8, 0.8, 0.8, 0.8, 0.8,
    ];

    // ── Build table rows ──────────────────────────────────────────────────
    final List<List<String>> dataRows = reportList.map((item) {
      return [
        '${item.sNo}',
        item.registrationNo,
        item.studentName,
        item.fatherName,
        item.className,
        item.section,
        fmtAmt(item.totalFee),
        fmtAmt(item.totalDiscount),
        fmtAmt(item.netFee),
        fmtAmt(item.totalPaid),
        fmtAmt(item.totalDue),
      ];
    }).toList();

    // Totals row
    final List<String> totalRow = [
      'Total', '', '', '', '', '',
      fmtAmt(sumTotalFee),
      fmtAmt(sumTotalDiscount),
      fmtAmt(sumNetFee),
      fmtAmt(sumTotalPaid),
      fmtAmt(sumTotalDue),
    ];

    // ── PDF page builder ──────────────────────────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title bar
            pw.Container(
              width: double.infinity,
              color: const PdfColor.fromInt(0xFF004D40),
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: pw.Text(
                'Student Wise Yearly Fee Report',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            // Session + summary row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Session: $sessionLabel',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Total Students: $totalStudents',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (context) => [
          // ── Data table ───────────────────────────────────────────────
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: dataRows,
            headerStyle: headerStyle,
            cellStyle: cellStyle,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF004D40),
            ),
            rowDecoration: const pw.BoxDecoration(),
            oddRowDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF0F9F8),
            ),
            cellAlignments: {
              0: pw.Alignment.center,
              6: pw.Alignment.centerRight,
              7: pw.Alignment.centerRight,
              8: pw.Alignment.centerRight,
              9: pw.Alignment.centerRight,
              10: pw.Alignment.centerRight,
            },
            columnWidths: {
              for (int i = 0; i < colWidths.length; i++)
                i: pw.FlexColumnWidth(colWidths[i]),
            },
            border: pw.TableBorder.all(
              color: PdfColor.fromInt(0xFFCCCCCC),
              width: 0.5,
            ),
          ),

          pw.SizedBox(height: 2),

          // ── Totals row ───────────────────────────────────────────────
          pw.Container(
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF004D40),
            ),
            child: pw.Row(
              children: List.generate(headers.length, (i) {
                return pw.Expanded(
                  flex: (colWidths[i] * 10).toInt(),
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 5, horizontal: 4),
                    child: pw.Text(
                      totalRow[i],
                      style: totalStyle,
                      textAlign: i >= 6
                          ? pw.TextAlign.right
                          : pw.TextAlign.left,
                    ),
                  ),
                );
              }),
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Summary box at bottom ────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                  color: PdfColor.fromInt(0xFF004D40), width: 0.8),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _pdfSummaryItem('Total Fee', fmtAmt(sumTotalFee)),
                _pdfSummaryItem('Discount', fmtAmt(sumTotalDiscount)),
                _pdfSummaryItem('Net Fee', fmtAmt(sumNetFee)),
                _pdfSummaryItem('Paid', fmtAmt(sumTotalPaid)),
                _pdfSummaryItem('Due', fmtAmt(sumTotalDue)),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated on: ${DateTime.now().toString().substring(0, 16)}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF004D40),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Save PDF to device Downloads / temp directory ─────────────────────────
  Future<void> downloadPdf() async {
    if (reportList.isEmpty) {
      Get.snackbar('Error', 'No data to export',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isPdfGenerating.value = true;

      final Uint8List bytes = await _generatePdfBytes();

      // Save to Downloads (Android) or Documents (iOS)
      final Directory dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final String sessionLabel =
      (selectedSession.value?.session ?? 'report')
          .replaceAll(RegExp(r'[^\w\-]'), '_');
      final String fileName =
          'StudentWiseYearlyReport_${sessionLabel}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final File file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes);

      Get.snackbar(
        'Downloaded ✅',
        'Saved to: ${file.path}',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('PDF download error: $e');
      Get.snackbar('Error', 'Failed to save PDF: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPdfGenerating.value = false;
    }
  }

  // ── Share PDF via share sheet ─────────────────────────────────────────────
  Future<void> sharePdf() async {
    if (reportList.isEmpty) {
      Get.snackbar('Error', 'No data to share',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isPdfGenerating.value = true;

      final Uint8List bytes = await _generatePdfBytes();

      // Write to temp file
      final Directory tempDir = await getTemporaryDirectory();
      final String sessionLabel =
      (selectedSession.value?.session ?? 'report')
          .replaceAll(RegExp(r'[^\w\-]'), '_');
      final String fileName =
          'StudentWiseYearlyReport_$sessionLabel.pdf';
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Share
      await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: 'application/pdf')],
        subject: 'Student Wise Yearly Fee Report - $sessionLabel',
        text:
        'Student Wise Yearly Fee Report for session: $sessionLabel\nTotal Students: $totalStudents',
      );
    } catch (e) {
      debugPrint('PDF share error: $e');
      Get.snackbar('Error', 'Failed to share PDF: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPdfGenerating.value = false;
    }
  }
}