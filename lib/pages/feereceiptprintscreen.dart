import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../controller/home_page_controller.dart';
import '../models/feeprintalldetail.dart';
import '../models/feeprintreceiptschname.dart';
import '../res/app_url.dart';

String _fmtDt(DateTime? dt) {
  if (dt == null) return 'N/A';
  return DateFormat('dd-MM-yyyy').format(dt);
}

class FeeReceiptPrintScreen extends StatefulWidget {
  const FeeReceiptPrintScreen({Key? key}) : super(key: key);

  @override
  State<FeeReceiptPrintScreen> createState() => _FeeReceiptPrintScreenState();
}

class _FeeReceiptPrintScreenState extends State<FeeReceiptPrintScreen> {
  bool _loading = true;
  String? _error;

  List<FeeReceiptAllDetailModel> _feeDetails = [];
  PreschoolReceiptModel? _studentData;

  late int _studentId;
  late String _session;
  late String _receiptNo;

  // Same accent color used everywhere (screen + both print copies) so
  // Parents Copy & School Copy always look identical in color.
  static const Color kAccentColor = Color(0xFF97144D);

  String get _dynamicSchoolLogoUrl {
    try {
      final dashCtrl = Get.find<DashboardScreenController>();
      final logoPath = dashCtrl.schoollogo.value;
      if (logoPath.isNotEmpty) {
        return '${AppUrl.dashurl}/$logoPath';
      }
    } catch (_) {}
    return '';
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _studentId = args['studentId'] ?? 0;
    _session   = args['session']   ?? '';
    _receiptNo = args['receiptNo'] ?? '';
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Future.wait([_fetchFeeDetails(), _fetchStudentData()]);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchFeeDetails() async {
    final url = Uri.parse("${AppUrl.base_url}api/Receipt/GetPaymentDetails");
    final body = jsonEncode({
      "studentId": _studentId,
      "session":   _session,
      "receiptNo": _receiptNo,
    });
    final res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final raw  = json['listData'] as List? ?? [];
      _feeDetails = raw
          .map((e) => FeeReceiptAllDetailModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("GetPaymentDetails failed: ${res.statusCode}");
    }
  }

  Future<void> _fetchStudentData() async {
    final url = Uri.parse("${AppUrl.base_url}api/Receipt/GetReceiptStudentData");
    final body = jsonEncode({
      "studentId": _studentId,
      "session":   _session,
      "receiptNo": _receiptNo,
    });
    final res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final raw  = json['listData'] as List? ?? [];
      if (raw.isNotEmpty) {
        _studentData =
            PreschoolReceiptModel.fromJson(raw.first as Map<String, dynamic>);
      }
    } else {
      throw Exception("GetReceiptStudentData failed: ${res.statusCode}");
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Builds ONE combined PDF page containing BOTH copies side-by-side
  // (Parents Copy on the left, School Copy on the right), separated by
  // a dashed "Cut Here" divider — exactly like the reference layout.
  // Both buttons ("Print Parents Copy" / "Print School Copy") call this
  // SAME function so the printed output is always identical.
  // ─────────────────────────────────────────────────────────────────
  Future<Uint8List> _buildCombinedPdf() async {
    final pdf   = pw.Document();
    final s     = _studentData;
    final items = _feeDetails;
    if (s == null || items.isEmpty) return pdf.save();

    pw.ImageProvider? pdfLogo;
    final logoUrl = _dynamicSchoolLogoUrl;
    if (logoUrl.isNotEmpty) {
      try {
        final logoRes = await http.get(Uri.parse(logoUrl));
        if (logoRes.statusCode == 200) {
          pdfLogo = pw.MemoryImage(logoRes.bodyBytes);
        }
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (ctx) => pw.Container(
          // Outer border for the whole printed page (border lines on the sides)
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey800, width: 1),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Expanded(
                child: _buildReceiptHalf(
                  copyLabel: "Parents Copy",
                  items: items,
                  s: s,
                  logo: pdfLogo,
                ),
              ),
              _buildCutDivider(),
              pw.Expanded(
                child: _buildReceiptHalf(
                  copyLabel: "School Copy",
                  items: items,
                  s: s,
                  logo: pdfLogo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }

  // One half of the page (a single receipt copy) — reused for both sides.
  pw.Widget _buildReceiptHalf({
    required String copyLabel,
    required List<FeeReceiptAllDetailModel> items,
    required PreschoolReceiptModel s,
    pw.ImageProvider? logo,
  }) {
    final first      = items.first;
    final totalPaid  = items.fold<double>(0, (sum, e) => sum + (e.payAmount ?? 0));
    final totalDue   = items.fold<double>(0, (sum, e) => sum + (e.dueAmount ?? 0));
    final totalAmt   = items.fold<double>(0, (sum, e) => sum + (e.totalAmount ?? 0));

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Text(
              copyLabel,
              style: pw.TextStyle(
                fontSize: 8,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey700,
              ),
            ),
          ),

          // ── School header ──
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Container(
                    width: 55,
                    height: 55,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                if (logo != null) pw.SizedBox(height: 4),
                pw.Text(
                  s.schoolName ?? '',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "Phone: ${s.schoolPhone ?? ''} , Email: ${s.schoolEmail ?? ''}",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7),
                ),
                pw.Text(
                  s.schoolAddress ?? '',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // ── "FEE RECEIPT" heading box ──
          pw.Container(
            width: double.infinity,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border.all(color: PdfColors.black, width: 0.8),
            ),
            child: pw.Text(
              "FEE RECEIPT",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),

          pw.SizedBox(height: 8),

          // ── Info rows ──
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pRow("Receipt No", first.receiptno ?? _receiptNo),
                    _pRow("Name", s.studentName ?? ''),
                    _pRow("Parents Name", s.fatherName ?? ''),
                    _pRow("Class/Sec", "${s.className ?? ''} / ${s.sectionName ?? ''}"),
                    _pRow("Admission No", first.admissionNo ?? 'N/A'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pRow("Payment Date", _fmtDt(first.payDate)),
                    _pRow("Registration No.", s.registrationNo ?? ''),
                    _pRow("Academic Year", s.session ?? ''),
                    _pRow("Mobile No", s.phone ?? ''),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 8),

          // ── Fee table ──
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FixedColumnWidth(18),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(1.4),
              4: pw.FlexColumnWidth(1.4),
              5: pw.FlexColumnWidth(1.2),
              6: pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.teal700),
                children: [
                  _pTH("S.No"), _pTH("Fee Type"), _pTH("Description"),
                  _pTH("Fees\nAmount"), _pTH("Discount\nAmount"), _pTH("Due"), _pTH("Paid"),
                ],
              ),
              ...items.asMap().entries.map((e) => pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: e.key.isOdd ? PdfColors.grey100 : PdfColors.white),
                children: [
                  _pTC("${e.key + 1}"),
                  _pTC(e.value.feetype  ?? ''),
                  _pTC(e.value.feeMonth ?? ''),
                  _pTC("${e.value.totalAmount?.toStringAsFixed(0) ?? 0}"),
                  _pTC("${e.value.discount?.toStringAsFixed(0)    ?? 0}"),
                  _pTC("${e.value.dueAmount?.toStringAsFixed(0)   ?? 0}"),
                  _pTC("${e.value.payAmount?.toStringAsFixed(0)   ?? 0}"),
                ],
              )),
            ],
          ),

          pw.SizedBox(height: 6),

          // ── Totals ──
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  "Pay Mode : ${first.paymentMode ?? 'N/A'}",
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.Text(
                "Total Due: ${totalDue.toStringAsFixed(0)} ,  ",
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                "Total Amount : ${totalAmt.toStringAsFixed(0)}",
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // ── Signatory ──
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("For ${s.schoolName ?? ''}",
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 16),
                  pw.Text("Authorized Signatory",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dashed vertical divider with rotated "Cut Here" text between the two copies.
  pw.Widget _buildCutDivider() {
    return pw.Container(
      width: 20,
      alignment: pw.Alignment.center,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.Column(
            mainAxisSize: pw.MainAxisSize.max,
            children: List.generate(
              40,
                  (i) => pw.Expanded(
                child: pw.Container(
                  width: 1,
                  margin: const pw.EdgeInsets.symmetric(vertical: 1.2),
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ),
          pw.Transform.rotate(
            angle: -math.pi / 2,
            child: pw.Container(
              color: PdfColors.white,
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: pw.Text(
                "- - - Cut Here - - -",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 68,
          child: pw.Text(label,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ),
        pw.Text(" : ", style: const pw.TextStyle(fontSize: 8)),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  pw.Widget _pTH(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(3.5),
    child: pw.Text(t,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
            color: PdfColors.white, fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pTC(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(3.5),
    child: pw.Text(t,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 7.5)),
  );

  // Called by BOTH print buttons — always prints Parents Copy + School Copy together.
  void _printBoth() async {
    final bytes = await _buildCombinedPdf();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: "$_receiptNo-FeeReceipt",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          "Receipt: $_receiptNo",
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: kAccentColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchAll, child: const Text("Retry")),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Same accent color on BOTH cards (as requested) — only the
            // label differs. Both "Print" buttons print the combined PDF.
            _ReceiptCopyCard(
              copyLabel:   "Parents Copy",
              accentColor: kAccentColor,
              feeDetails:  _feeDetails,
              studentData: _studentData,
              receiptNo:   _receiptNo,
              logoUrl:     _dynamicSchoolLogoUrl,
              onPrint:     _printBoth,
            ),
            const SizedBox(height: 20),
            _ReceiptCopyCard(
              copyLabel:   "School Copy",
              accentColor: kAccentColor,
              feeDetails:  _feeDetails,
              studentData: _studentData,
              receiptNo:   _receiptNo,
              logoUrl:     _dynamicSchoolLogoUrl,
              onPrint:     _printBoth,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Single receipt copy card (on-screen preview) ──────────────────────────

class _ReceiptCopyCard extends StatelessWidget {
  final String       copyLabel;
  final Color        accentColor;
  final List<FeeReceiptAllDetailModel> feeDetails;
  final PreschoolReceiptModel?         studentData;
  final String       receiptNo;
  final String       logoUrl;
  final VoidCallback onPrint;

  const _ReceiptCopyCard({
    required this.copyLabel,
    required this.accentColor,
    required this.feeDetails,
    required this.studentData,
    required this.receiptNo,
    required this.logoUrl,
    required this.onPrint,
  });

  Widget _buildSchoolLogo() {
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl:    logoUrl,
          width:       64,
          height:      64,
          fit:         BoxFit.contain,
          placeholder: (_, __) => const SizedBox(width: 64, height: 64),
          errorWidget: (_, __, ___) => const SizedBox(width: 0, height: 0),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final s         = studentData;
    final items     = feeDetails;
    final first     = items.isNotEmpty ? items.first : null;
    final totalPaid = items.fold<double>(0, (sum, e) => sum + (e.payAmount ?? 0));
    final totalDue  = items.fold<double>(0, (sum, e) => sum + (e.dueAmount ?? 0));

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Title bar ──
          Container(
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "FEE RECEIPT",
                  style: TextStyle(
                      color:         Colors.white,
                      fontWeight:    FontWeight.w800,
                      fontSize:      14,
                      letterSpacing: 1.1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    copyLabel,
                    style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── School info ──
          if (s != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSchoolLogo(),
                  if (logoUrl.isNotEmpty) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.schoolName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize:   15,
                              fontWeight: FontWeight.w800,
                              color:      accentColor),
                        ),
                        const SizedBox(height: 3),
                        if ((s.schoolPhone ?? '').isNotEmpty ||
                            (s.schoolEmail ?? '').isNotEmpty)
                          Text(
                            "Ph: ${s.schoolPhone ?? ''}  |  ${s.schoolEmail ?? ''}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                        if ((s.schoolAddress ?? '').isNotEmpty)
                          Text(
                            s.schoolAddress ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE8EAF6)),
          ),

          // ── Student info (includes Admission No) ──
          if (s != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoTileV("Receipt No",    first?.receiptno ?? receiptNo, accentColor),
                        _infoTileV("Name",          s.studentName ?? '',           accentColor),
                        _infoTileV("Parents Name",  s.fatherName  ?? '',           accentColor),
                        _infoTileV("Class / Sec",
                            "${s.className ?? ''} / ${s.sectionName ?? ''}",       accentColor),
                        _infoTileV("Admission No",  first?.admissionNo ?? 'N/A',   accentColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoTileV("Payment Date",     _fmtDt(first?.payDate),    accentColor),
                        _infoTileV("Registration No.", s.registrationNo ?? '',     accentColor),
                        _infoTileV("Academic Year",    s.session ?? '',            accentColor),
                        _infoTileV("Mobile No",        s.phone   ?? '',            accentColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ── Fee table ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 24,
                  ),
                  child: Table(
                    border: TableBorder.all(
                        color: const Color(0xFFE8EAF6), width: 0.8),
                    columnWidths: const {
                      0: FixedColumnWidth(34),
                      1: FlexColumnWidth(2.2),
                      2: FlexColumnWidth(1.8),
                      3: FlexColumnWidth(1.6),
                      4: FlexColumnWidth(1.6),
                      5: FlexColumnWidth(1.6),
                      6: FlexColumnWidth(1.6),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: accentColor),
                        children: [
                          _th("S.No "), _th("Fee Type"), _th("Month"),
                          _th("Amnt"), _th("Disct"), _th("Due"), _th("Paid"),
                        ],
                      ),
                      ...items.asMap().entries.map(
                            (entry) => TableRow(
                          decoration: BoxDecoration(
                            color: entry.key.isOdd
                                ? const Color(0xFFF5F5F5)
                                : Colors.white,
                          ),
                          children: [
                            _td("${entry.key + 1}"),
                            _td(entry.value.feetype  ?? ''),
                            _td(entry.value.feeMonth ?? ''),
                            _td("₹${entry.value.totalAmount?.toStringAsFixed(0) ?? 0}"),
                            _td("₹${entry.value.discount?.toStringAsFixed(0)    ?? 0}",
                                color: const Color(0xFFE53935)),
                            _td("₹${entry.value.dueAmount?.toStringAsFixed(0)   ?? 0}",
                                color: (entry.value.dueAmount ?? 0) > 0
                                    ? const Color(0xFFE53935)
                                    : null),
                            _td("₹${entry.value.payAmount?.toStringAsFixed(0)   ?? 0}",
                                color: const Color(0xFF2E7D32),
                                bold:  true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Summary chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing:    6,
              runSpacing: 4,
              children: [
                _chip("Pay Mode: ${first?.paymentMode ?? 'N/A'}",
                    Colors.grey.shade200, Colors.grey.shade700),
                _chip(
                    "Total Due: ₹${totalDue.toStringAsFixed(0)}",
                    totalDue > 0 ? const Color(0xFFFFEBEE) : Colors.grey.shade100,
                    totalDue > 0 ? const Color(0xFFE53935) : Colors.grey.shade600),
                _chip(
                    "Total Paid: ₹${totalPaid.toStringAsFixed(0)}",
                    const Color(0xFFE8F5E9),
                    const Color(0xFF2E7D32)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Footer — overflow-proof ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.print, size: 17, color: Color(0xFF37474F)),
                    label: Text(
                      "Print $copyLabel",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize:   13,
                          color:      Color(0xFF37474F)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD600),
                      foregroundColor: const Color(0xFF37474F),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "For ${s?.schoolName ?? ''}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Authorized Signatory",
                        style: TextStyle(
                            fontSize:   11,
                            fontWeight: FontWeight.w700,
                            color:      Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _infoTileV(String label, String value, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize:      10.5,
                  color:         Colors.grey.shade500,
                  fontWeight:    FontWeight.w500,
                  letterSpacing: 0.2)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize:   12.5,
                fontWeight: FontWeight.w700,
                color:      Color(0xFF1A237E)),
          ),
        ],
      ),
    );
  }

  Widget _th(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
    child: Text(text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color:      Colors.white,
            fontSize:   11,
            fontWeight: FontWeight.w700)),
  );

  Widget _td(String text, {Color? color, bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    child: Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize:   11.5,
            color:      color ?? const Color(0xFF37474F),
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
  );

  Widget _chip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label,
        style: TextStyle(
            fontSize:   12,
            color:      fg,
            fontWeight: FontWeight.w600)),
  );
}