// screens/daycare_fee_receipt_print_screen.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controller/home_page_controller.dart';
import '../models/paymentReceiptDayCare.dart';
import '../res/app_url.dart';

String _fmtDt(DateTime? dt) =>
    dt == null ? 'N/A' : DateFormat('dd-MM-yyyy').format(dt);

class DaycareFeeReceiptPrintScreen extends StatefulWidget {
  const DaycareFeeReceiptPrintScreen({Key? key}) : super(key: key);

  @override
  State<DaycareFeeReceiptPrintScreen> createState() =>
      _DaycareFeeReceiptPrintScreenState();
}

class _DaycareFeeReceiptPrintScreenState
    extends State<DaycareFeeReceiptPrintScreen> {
  bool _loading = true;
  String? _error;
  List<DaycareReceiptModel> _feeDetails = [];

  late int    _studentId;
  late String _session;
  late String _receiptNo;

  String get _dynamicSchoolLogoUrl {
    try {
      final dashCtrl = Get.find<DashboardScreenController>();
      final logoPath = dashCtrl.schoollogo.value;
      if (logoPath.isNotEmpty) return '${AppUrl.dashurl}/$logoPath';
    } catch (_) {}
    return '';
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    // Handle both int and String coming from different callers
    final rawId = args['studentId'];
    _studentId  = (rawId is int) ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
    _session    = args['session']?.toString()   ?? '';
    _receiptNo  = args['receiptNo']?.toString() ?? '';
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    // Reset state
    setState(() {
      _loading    = true;
      _error      = null;
      _feeDetails = [];
    });

    try {
      final url = Uri.parse(
          "${AppUrl.base_url}api/Receipt/GetDaycarePaymentDetails");

      final body = jsonEncode({
        "studentId": _studentId,
        "session":   _session,
        "receiptNo": _receiptNo,
      });

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final raw     = decoded['listData'] as List? ?? [];
        final parsed  = raw
            .map((e) => DaycareReceiptModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Assign then setState so widget rebuilds with data
        setState(() {
          _feeDetails = parsed;
          _loading    = false;
        });
      } else {
        setState(() {
          _error   = "Failed to load receipt (${res.statusCode})";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error   = e.toString();
        _loading = false;
      });
    }
  }

  // ─── PDF ────────────────────────────────────────────────────────────────────

  Future<Uint8List> _buildPdf({required bool isParentCopy}) async {
    final pdf   = pw.Document();
    final items = _feeDetails;
    if (items.isEmpty) return pdf.save();

    final first     = items.first;
    final totalPaid = items.fold<double>(0, (s, e) => s + (e.payAmount   ?? 0));
    final totalDue  = items.fold<double>(0, (s, e) => s + (e.dueAmount   ?? 0));
    final totalDisc = items.fold<double>(0, (s, e) => s + (e.discount    ?? 0));
    final totalAmt  = items.fold<double>(0, (s, e) => s + (e.totalAmount ?? 0));

    pw.ImageProvider? pdfLogo;
    final logoUrl = _dynamicSchoolLogoUrl;
    if (logoUrl.isNotEmpty) {
      try {
        final r = await http.get(Uri.parse(logoUrl));
        if (r.statusCode == 200) pdfLogo = pw.MemoryImage(r.bodyBytes);
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(18),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (pdfLogo != null)
                    pw.Container(
                        width: 60, height: 60,
                        child: pw.Image(pdfLogo, fit: pw.BoxFit.contain)),
                  if (pdfLogo != null) pw.SizedBox(height: 5),
                  pw.Text(first.schoolName ?? '',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                      "Ph: ${first.phone ?? ''}  |  ${first.email ?? ''}",
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(first.schoolAddress ?? '',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.SizedBox(height: 3),
                  pw.Text(
                      isParentCopy ? "Parents Copy" : "School Copy",
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text("DAY CARE FEE RECEIPT",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    decoration: pw.TextDecoration.underline)),
            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pCol("Receipt No",  first.receiptno ?? _receiptNo),
                      _pCol("Name",        first.studentName ?? ''),
                      _pCol("Father Name", first.fatherName  ?? ''),
                      _pCol("Fee Month",   first.feeMonth    ?? ''),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pCol("Payment Date", _fmtDt(first.payDate)),
                      _pCol("Reg. No.",     first.registrationNo ?? ''),
                      _pCol("Session",      first.session        ?? ''),
                      _pCol("Pay Mode",     first.paymentMode    ?? ''),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: const {
                0: pw.FixedColumnWidth(22),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(1.5),
                4: pw.FlexColumnWidth(1.5),
                5: pw.FlexColumnWidth(1.5),
                6: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF97144D)),
                  children: [
                    _pTH("S.No"), _pTH("Fee Type"), _pTH("Month"),
                    _pTH("Amount"), _pTH("Discount"), _pTH("Due"), _pTH("Paid"),
                  ],
                ),
                ...items.asMap().entries.map((e) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: e.key.isOdd ? PdfColors.grey100 : PdfColors.white),
                  children: [
                    _pTC("${e.key + 1}"),
                    _pTC(e.value.feetype      ?? ''),
                    _pTC(e.value.feeMonth     ?? ''),
                    _pTC((e.value.totalAmount ?? 0).toStringAsFixed(0)),
                    _pTC((e.value.discount    ?? 0).toStringAsFixed(0)),
                    _pTC((e.value.dueAmount   ?? 0).toStringAsFixed(0)),
                    _pTC((e.value.payAmount   ?? 0).toStringAsFixed(0)),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Row(children: [
              pw.Text(
                "Pay Mode: ${first.paymentMode ?? 'N/A'}   "
                    "Total: ${totalAmt.toStringAsFixed(0)}   "
                    "Disc: ${totalDisc.toStringAsFixed(0)}   "
                    "Due: ${totalDue.toStringAsFixed(0)}   ",
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                "Paid: ${totalPaid.toStringAsFixed(0)}",
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ]),
            if ((first.remarks ?? '').isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text("Remarks: ${first.remarks}",
                  style: const pw.TextStyle(fontSize: 7.5)),
            ],
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("For ${first.schoolName ?? ''}",
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
      ),
    );
    return pdf.save();
  }

  pw.Widget _pCol(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.SizedBox(height: 1),
        pw.Text(value,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
      ],
    ),
  );

  pw.Widget _pTH(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(3.5),
    child: pw.Text(t,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
            color:      PdfColors.white,
            fontSize:   7.5,
            fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pTC(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(3.5),
    child: pw.Text(t,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 7.5)),
  );

  void _doPrint({required bool isParentCopy}) async {
    final bytes = await _buildPdf(isParentCopy: isParentCopy);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: "$_receiptNo-${isParentCopy ? 'ParentsCopy' : 'SchoolCopy'}",
    );
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────

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
        backgroundColor: const Color(0xFF97144D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF97144D)))
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _fetchDetails,
                  child: const Text("Retry")),
            ],
          ),
        ),
      )
          : _feeDetails.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text("No receipt data found.",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchDetails,
                child: const Text("Retry")),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DaycareReceiptCopyCard(
              copyLabel:   "Parents Copy",
              accentColor: const Color(0xFF97144D),
              feeDetails:  _feeDetails,
              receiptNo:   _receiptNo,
              logoUrl:     _dynamicSchoolLogoUrl,
              onPrint:     () => _doPrint(isParentCopy: true),
            ),
            const SizedBox(height: 20),
            _DaycareReceiptCopyCard(
              copyLabel:   "School Copy",
              accentColor: const Color(0xFF1565C0),
              feeDetails:  _feeDetails,
              receiptNo:   _receiptNo,
              logoUrl:     _dynamicSchoolLogoUrl,
              onPrint:     () => _doPrint(isParentCopy: false),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Receipt Copy Card ─────────────────────────────────────────────────────────

class _DaycareReceiptCopyCard extends StatelessWidget {
  final String copyLabel;
  final Color  accentColor;
  final List<DaycareReceiptModel> feeDetails;
  final String receiptNo;
  final String logoUrl;
  final VoidCallback onPrint;

  const _DaycareReceiptCopyCard({
    required this.copyLabel,
    required this.accentColor,
    required this.feeDetails,
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
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final items     = feeDetails;
    final first     = items.isNotEmpty ? items.first : null;
    final totalPaid = items.fold<double>(0, (s, e) => s + (e.payAmount  ?? 0));
    final totalDue  = items.fold<double>(0, (s, e) => s + (e.dueAmount  ?? 0));

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
              color:        accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "DAY CARE FEE RECEIPT",
                  style: TextStyle(
                      color:         Colors.white,
                      fontWeight:    FontWeight.w800,
                      fontSize:      13,
                      letterSpacing: 1.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(copyLabel,
                      style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // ── School info ──
          if (first != null)
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
                          first.schoolName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize:   15,
                              fontWeight: FontWeight.w800,
                              color:      accentColor),
                        ),
                        const SizedBox(height: 3),
                        if ((first.phone ?? '').isNotEmpty ||
                            (first.email ?? '').isNotEmpty)
                          Text(
                            "Ph: ${first.phone ?? ''}  |  ${first.email ?? ''}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color:    Colors.grey.shade600),
                          ),
                        if ((first.schoolAddress ?? '').isNotEmpty)
                          Text(
                            first.schoolAddress ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color:    Colors.grey.shade600),
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

          // ── Student info 2-col ──
          if (first != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoTileV("Receipt No",  first.receiptno ?? receiptNo, accentColor),
                        _infoTileV("Name",        first.studentName ?? '',      accentColor),
                        _infoTileV("Father Name", first.fatherName  ?? '',      accentColor),
                        _infoTileV("Fee Month",   first.feeMonth    ?? '',      accentColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoTileV("Payment Date", _fmtDt(first.payDate),      accentColor),
                        _infoTileV("Reg. No.",     first.registrationNo ?? '', accentColor),
                        _infoTileV("Session",      first.session        ?? '', accentColor),
                        _infoTileV("Pay Mode",     first.paymentMode    ?? '', accentColor),
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
                          _th("S.No"), _th("Fee Type"), _th("Month"),
                          _th("Amount"), _th("Discount"),
                          _th("Due"), _th("Paid"),
                        ],
                      ),
                      ...items.asMap().entries.map((entry) => TableRow(
                        decoration: BoxDecoration(
                          color: entry.key.isOdd
                              ? const Color(0xFFF5F5F5)
                              : Colors.white,
                        ),
                        children: [
                          _td("${entry.key + 1}"),
                          _td(entry.value.feetype  ?? ''),
                          _td(entry.value.feeMonth ?? ''),
                          _td("₹${(entry.value.totalAmount ?? 0).toStringAsFixed(0)}"),
                          _td("₹${(entry.value.discount    ?? 0).toStringAsFixed(0)}",
                              color: const Color(0xFFE53935)),
                          _td("₹${(entry.value.dueAmount   ?? 0).toStringAsFixed(0)}",
                              color: (entry.value.dueAmount ?? 0) > 0
                                  ? const Color(0xFFE53935)
                                  : null),
                          _td("₹${(entry.value.payAmount   ?? 0).toStringAsFixed(0)}",
                              color: const Color(0xFF2E7D32),
                              bold:  true),
                        ],
                      )),
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
                    totalDue > 0
                        ? const Color(0xFFFFEBEE)
                        : Colors.grey.shade100,
                    totalDue > 0
                        ? const Color(0xFFE53935)
                        : Colors.grey.shade600),
                _chip(
                    "Total Paid: ₹${totalPaid.toStringAsFixed(0)}",
                    const Color(0xFFE8F5E9),
                    const Color(0xFF2E7D32)),
                if ((first?.remarks ?? '').isNotEmpty)
                  _chip("Remarks: ${first!.remarks}",
                      const Color(0xFFFFF8E1),
                      const Color(0xFFF57F17)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.print,
                        size: 17, color: Color(0xFF37474F)),
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
                        "For ${first?.schoolName ?? ''}",
                        maxLines: 2,
                        overflow:  TextOverflow.ellipsis,
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
                  fontSize:   10.5,
                  color:      Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize:   12.5,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF1A237E))),
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
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label,
        style: TextStyle(
            fontSize:   12,
            color:      fg,
            fontWeight: FontWeight.w600)),
  );
}