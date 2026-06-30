import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../controller/home_page_controller.dart';
import '../models/id_card_print_model.dart';
import '../res/app_url.dart';

const _imgBase = 'https://playschool.edubloom.in';

class IdCardTheme {
  final String name;
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color ribbonBg;
  final Color ribbonText;
  final Color footerBg;
  final PdfColor pdfPrimary;
  final PdfColor pdfPrimaryLight;
  final PdfColor pdfAccent;
  final PdfColor pdfRibbonBg;
  final PdfColor pdfRibbonText;

  const IdCardTheme({
    required this.name,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.ribbonBg,
    required this.ribbonText,
    required this.footerBg,
    required this.pdfPrimary,
    required this.pdfPrimaryLight,
    required this.pdfAccent,
    required this.pdfRibbonBg,
    required this.pdfRibbonText,
  });
}

final List<IdCardTheme> kIdCardThemes = [
  // 1. Teal (default)
  const IdCardTheme(
    name: 'Teal',
    primary: Color(0xFF00695C),
    primaryLight: Color(0xFF26A69A),
    accent: Color(0xFF80CBC4),
    ribbonBg: Color(0xFFE0F2F1),
    ribbonText: Color(0xFF00695C),
    footerBg: Color(0xFF00695C),
    pdfPrimary: PdfColors.teal800,
    pdfPrimaryLight: PdfColors.teal400,
    pdfAccent: PdfColors.teal200,
    pdfRibbonBg: PdfColors.teal100,
    pdfRibbonText: PdfColors.teal800,
  ),
  // 2. Navy Blue (was Royal Blue)
  const IdCardTheme(
    name: 'Navy Blue',
    primary: Color(0xFF0A2342),
    primaryLight: Color(0xFF1B4F8A),
    accent: Color(0xFF90CAF9),
    ribbonBg: Color(0xFFE8EDF5),
    ribbonText: Color(0xFF0A2342),
    footerBg: Color(0xFF0A2342),
    pdfPrimary: PdfColors.blueGrey900,
    pdfPrimaryLight: PdfColors.blueGrey700,
    pdfAccent: PdfColors.blueGrey200,
    pdfRibbonBg: PdfColors.blueGrey50,
    pdfRibbonText: PdfColors.blueGrey900,
  ),
  // 3. Gray (was Purple)
  const IdCardTheme(
    name: 'Gray',
    primary: Color(0xFF424242),
    primaryLight: Color(0xFF757575),
    accent: Color(0xFFBDBDBD),
    ribbonBg: Color(0xFFF5F5F5),
    ribbonText: Color(0xFF424242),
    footerBg: Color(0xFF424242),
    pdfPrimary: PdfColors.grey800,
    pdfPrimaryLight: PdfColors.grey600,
    pdfAccent: PdfColors.grey400,
    pdfRibbonBg: PdfColors.grey100,
    pdfRibbonText: PdfColors.grey800,
  ),
  // 4. Yellow (was Crimson)
  const IdCardTheme(
    name: 'Yellow',
    primary: Color(0xFFF9A825),
    primaryLight: Color(0xFFFFCC02),
    accent: Color(0xFFFFE082),
    ribbonBg: Color(0xFFFFFDE7),
    ribbonText: Color(0xFFF57F17),
    footerBg: Color(0xFFF9A825),
    pdfPrimary: PdfColors.amber800,
    pdfPrimaryLight: PdfColors.amber400,
    pdfAccent: PdfColors.amber200,
    pdfRibbonBg: PdfColors.amber50,
    pdfRibbonText: PdfColors.amber900,
  ),
  // 5. Forest Green
  const IdCardTheme(
    name: 'Forest',
    primary: Color(0xFF2E7D32),
    primaryLight: Color(0xFF66BB6A),
    accent: Color(0xFFA5D6A7),
    ribbonBg: Color(0xFFE8F5E9),
    ribbonText: Color(0xFF2E7D32),
    footerBg: Color(0xFF2E7D32),
    pdfPrimary: PdfColors.green800,
    pdfPrimaryLight: PdfColors.green400,
    pdfAccent: PdfColors.green200,
    pdfRibbonBg: PdfColors.green50,
    pdfRibbonText: PdfColors.green800,
  ),
  // 6. Midnight Navy (original)
  const IdCardTheme(
    name: 'Navy',
    primary: Color(0xFF0D2137),
    primaryLight: Color(0xFF1E6091),
    accent: Color(0xFF90CAF9),
    ribbonBg: Color(0xFFE8EAF6),
    ribbonText: Color(0xFF0D2137),
    footerBg: Color(0xFF0D2137),
    pdfPrimary: PdfColors.blueGrey900,
    pdfPrimaryLight: PdfColors.blueGrey600,
    pdfAccent: PdfColors.blueGrey200,
    pdfRibbonBg: PdfColors.blueGrey50,
    pdfRibbonText: PdfColors.blueGrey900,
  ),
  // 7. Black & White
  const IdCardTheme(
    name: 'B&W',
    primary: Color(0xFF000000),
    primaryLight: Color(0xFF333333),
    accent: Color(0xFF888888),
    ribbonBg: Color(0xFFF0F0F0),
    ribbonText: Color(0xFF000000),
    footerBg: Color(0xFF000000),
    pdfPrimary: PdfColors.black,
    pdfPrimaryLight: PdfColors.grey700,
    pdfAccent: PdfColors.grey400,
    pdfRibbonBg: PdfColors.grey200,
    pdfRibbonText: PdfColors.black,
  ),
];

const _textPrimary   = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);

class IdCardPrintScreen extends StatefulWidget {
  final int    studentId;
  final String schoolId;
  final String currentSession;

  const IdCardPrintScreen({
    super.key,
    required this.studentId,
    required this.schoolId,
    required this.currentSession,
  });

  @override
  State<IdCardPrintScreen> createState() => _IdCardPrintScreenState();
}

class _IdCardPrintScreenState extends State<IdCardPrintScreen> {
  bool   _isLoading = true;
  String? _error;
  IdCardStudentData? _student;

  int _themeIndex = 0;
  IdCardTheme get _theme => kIdCardThemes[_themeIndex];

  Offset _studentImgOffset = Offset.zero;
  double _studentImgScale  = 1.0;
  Offset _fatherImgOffset  = Offset.zero;
  double _fatherImgScale   = 1.0;
  Offset _motherImgOffset  = Offset.zero;
  double _motherImgScale   = 1.0;

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
    _fetchIdCard();
  }

  Future<void> _fetchIdCard() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final uri = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/GetStudentDetailsIdCardApp'
            '?studentIds=${widget.studentId}'
            '&schoolId=${widget.schoolId}'
            '&currentSession=${widget.currentSession}',
      );
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final model = IdCardPrintModel.fromJson(json);
        if (model.isSuccess == true &&
            model.data != null &&
            model.data!.isNotEmpty) {
          setState(() => _student = model.data!.first);
        } else {
          setState(() => _error = model.messages ?? 'Failed to load data');
        }
      } else {
        setState(() => _error = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printFront() async {
    final s = _student;
    if (s == null) return;
    final t = _theme;

    pw.ImageProvider? pdfLogo;
    final logoUrl = _dynamicSchoolLogoUrl;
    if (logoUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(logoUrl));
        if (res.statusCode == 200) pdfLogo = pw.MemoryImage(res.bodyBytes);
      } catch (_) {}
    }

    if (pdfLogo == null && s.logoWithName != null) {
      try {
        final res = await http.get(Uri.parse('$_imgBase/Upload/school/${s.logoWithName}'));
        if (res.statusCode == 200) pdfLogo = pw.MemoryImage(res.bodyBytes);
      } catch (_) {}
    }

    pw.ImageProvider? pdfStudentImg;
    if (s.studentPic != null) {
      try {
        final res = await http.get(Uri.parse('$_imgBase${s.studentPic}'));
        if (res.statusCode == 200) pdfStudentImg = pw.MemoryImage(res.bodyBytes);
      } catch (_) {}
    }

    final dob = s.dateOfBirth != null
        ? DateFormat('dd MMM yyyy').format(s.dateOfBirth!)
        : '-';

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a6,
      margin: const pw.EdgeInsets.all(14),
      build: (ctx) => pw.ClipRRect(
        horizontalRadius: 12,
        verticalRadius: 12,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header
            pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [t.pdfPrimary, t.pdfPrimaryLight],
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (pdfLogo != null)
                    pw.Container(
                      width: 48, height: 48,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.white,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.ClipOval(child: pw.Image(pdfLogo, fit: pw.BoxFit.contain)),
                    ),
                  if (pdfLogo != null) pw.SizedBox(height: 4),
                  pw.Text(
                    (s.schoolName ?? '').toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11, letterSpacing: 0.6),
                  ),
                  if ((s.affiliated ?? '').isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(s.affiliated!, textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 7)),
                  ],
                  pw.SizedBox(height: 2),
                  pw.Text(s.schoolAddress ?? '', textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 7)),
                  pw.SizedBox(height: 2),
                  // Fixed: use text "Ph:" instead of unicode phone icon that doesn't render
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('Ph: ',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text(s.schoolPhone ?? '-',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 7)),
                    ],
                  ),
                ],
              ),
            ),
            // Ribbon
            pw.Container(
              color: t.pdfRibbonBg,
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text('STUDENT IDENTITY CARD',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold,
                      color: t.pdfRibbonText, letterSpacing: 2)),
            ),
            // Body
            pw.Expanded(
              child: pw.Container(
                color: PdfColors.white,
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 60, height: 68,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: t.pdfPrimaryLight, width: 1.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                            color: t.pdfRibbonBg,
                          ),
                          child: pdfStudentImg != null
                              ? pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(pdfStudentImg, fit: pw.BoxFit.cover,
                              alignment: pw.Alignment.topCenter,
                            ),
                          )
                              : pw.Center(
                            child: pw.Text(
                              s.studentName?.substring(0, 1) ?? '?',
                              style: pw.TextStyle(fontSize: 22, color: t.pdfPrimary, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: t.pdfPrimary,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                          ),
                          child: pw.Text(s.className ?? '-',
                              style: pw.TextStyle(color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(s.studentName ?? '-',
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                          pw.SizedBox(height: 1),
                          pw.Text('Reg: ${s.registrationNo ?? '-'}',
                              style: pw.TextStyle(fontSize: 7, color: t.pdfPrimaryLight, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 6),
                          _pRow('Father',    s.fatherName  ?? '-', t),
                          _pRow('Mother',    s.motherName  ?? '-', t),
                          _pRow('DOB',       dob, t),
                          _pRow('Blood Grp', s.bloodGroup  ?? '-', t),
                          _pRow('Section',   '${s.sectionName ?? '-'}', t),
                          if ((s.rollNo ?? '').isNotEmpty) _pRow('Roll No', s.rollNo!, t),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            pw.Container(
              color: t.pdfPrimary,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Session: ${s.session ?? '-'}',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 7)),
                  pw.Text(s.schoolEmail ?? '',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 7)),
                ],
              ),
            ),
          ],
        ),
      ),
    ));

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'IDCard_Front_${s.studentName ?? widget.studentId}',
    );
  }

  Future<void> _printBack() async {
    final s = _student;
    if (s == null) return;
    final t = _theme;

    pw.ImageProvider? pdfFatherImg;
    if (s.fatherPic != null) {
      try {
        final res = await http.get(Uri.parse('$_imgBase${s.fatherPic}'));
        if (res.statusCode == 200) pdfFatherImg = pw.MemoryImage(res.bodyBytes);
      } catch (_) {}
    }

    pw.ImageProvider? pdfMotherImg;
    if (s.motherPic != null) {
      try {
        final res = await http.get(Uri.parse('$_imgBase${s.motherPic}'));
        if (res.statusCode == 200) pdfMotherImg = pw.MemoryImage(res.bodyBytes);
      } catch (_) {}
    }

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a6,
      margin: const pw.EdgeInsets.all(14),
      build: (ctx) => pw.ClipRRect(
        horizontalRadius: 12,
        verticalRadius: 12,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [t.pdfPrimary, t.pdfPrimaryLight],
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Text(
                (s.schoolName ?? 'School').toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                color: PdfColors.white,
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 45, height: 50,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: t.pdfPrimaryLight, width: 1.5),
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                                  color: t.pdfRibbonBg,
                                ),
                                child: pdfFatherImg != null
                                    ? pw.ClipRRect(
                                  horizontalRadius: 6, verticalRadius: 6,
                                  child: pw.Image(pdfFatherImg, fit: pw.BoxFit.cover,
                                    alignment: pw.Alignment.topCenter,
                                  ),
                                )
                                    : pw.Center(child: pw.Text('F', style: pw.TextStyle(fontSize: 18, color: t.pdfPrimaryLight, fontWeight: pw.FontWeight.bold))),
                              ),
                              pw.SizedBox(height: 3),
                              // pw.Text('Father',
                              //     style: pw.TextStyle(fontSize: 7, color: t.pdfPrimaryLight, fontWeight: pw.FontWeight.bold)),
                              // pw.SizedBox(height: 2),
                              pw.Text(s.fatherName ?? '-',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                        pw.Container(width: 1, height: 80, color: t.pdfRibbonBg),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 45, height: 50,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: t.pdfPrimaryLight, width: 1.5),
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                                  color: t.pdfRibbonBg,
                                ),
                                child: pdfMotherImg != null
                                    ? pw.ClipRRect(
                                  horizontalRadius: 6, verticalRadius: 6,
                                  child: pw.Image(pdfMotherImg, fit: pw.BoxFit.cover,
                                    alignment: pw.Alignment.topCenter,
                                  ),
                                )
                                    : pw.Center(child: pw.Text('M', style: pw.TextStyle(fontSize: 18, color: t.pdfPrimaryLight, fontWeight: pw.FontWeight.bold))),
                              ),
                              pw.SizedBox(height: 3),
                              // pw.Text('Mother',
                              //     style: pw.TextStyle(fontSize: 7, color: t.pdfPrimaryLight, fontWeight: pw.FontWeight.bold)),
                              // pw.SizedBox(height: 2),
                              pw.Text(s.motherName ?? '-',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Divider(color: t.pdfRibbonBg),
                    pw.SizedBox(height: 6),
                    _pRow('Phone',     s.phone       ?? '-', t),
                    _pRow('WhatsApp',  s.whatsAppNo  ?? '-', t),
                    _pRow('Emergency', s.emergencyNo ?? '-', t),
                    _pRow('Email',     s.email       ?? '-', t),
                    _pRow('Address',   s.address     ?? '-', t),
                    if ((s.transportUser ?? '').toLowerCase() == 'yes') ...[
                      pw.SizedBox(height: 4),
                      pw.Divider(color: t.pdfRibbonBg),
                      pw.Text('Transport Details',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: t.pdfPrimary)),
                      pw.SizedBox(height: 3),
                      _pRow('Route No', s.routeNo     ?? '-', t),
                      _pRow('Stop',     s.pickupPoint ?? '-', t),
                    ],
                    pw.SizedBox(height: 6),
                    pw.Divider(color: t.pdfRibbonBg),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(7),
                      decoration: pw.BoxDecoration(
                        color: t.pdfRibbonBg,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        'If found, please return to the school.\n${s.schoolName ?? ''} | ${s.schoolAddress ?? ''}\nPh: ${s.schoolPhone ?? ''}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.Container(
              color: t.pdfPrimary,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Authorised Signature _______________',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 7)),
                ],
              ),
            ),
          ],
        ),
      ),
    ));

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'IDCard_Back_${s.studentName ?? widget.studentId}',
    );
  }

  pw.Widget _pRow(String label, String value, IdCardTheme t) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 55,
          child: pw.Text('$label :',
              style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.black)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _theme.primary,
        title: const Text(
          '🪪 ID Card Preview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            tooltip: 'Print Front',
            onPressed: _student != null ? _printFront : null,
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            tooltip: 'Print Back',
            onPressed: _student != null ? _printBack : null,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _theme.primary))
          : _error != null
          ? _buildError()
          : _buildIdCardView(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
          SizedBox(height: 12.h),
          Text(_error!, style: TextStyle(color: _textSecondary, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _theme.primary),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            onPressed: _fetchIdCard,
          ),
        ],
      ),
    );
  }

  Widget _buildIdCardView() {
    final s = _student!;
    return Column(
      children: [
        _buildThemeSelector(),
        Expanded(
          child: RefreshIndicator(
            color: _theme.primary,
            onRefresh: _fetchIdCard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                children: [
                  _buildSectionLabel('Front Side'),
                  SizedBox(height: 8.h),
                  _FrontCard(
                    student:           s,
                    dynamicLogoUrl:    _dynamicSchoolLogoUrl,
                    theme:             _theme,
                    imgOffset:         _studentImgOffset,
                    imgScale:          _studentImgScale,
                    onAdjust:          (o, scale) => setState(() {
                      _studentImgOffset = o;
                      _studentImgScale  = scale;
                    }),
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionLabel('Back Side'),
                  SizedBox(height: 8.h),
                  _BackCard(
                    student:          s,
                    theme:            _theme,
                    fatherOffset:     _fatherImgOffset,
                    fatherScale:      _fatherImgScale,
                    motherOffset:     _motherImgOffset,
                    motherScale:      _motherImgScale,
                    onFatherAdjust:   (o, scale) => setState(() {
                      _fatherImgOffset = o;
                      _fatherImgScale  = scale;
                    }),
                    onMotherAdjust:   (o, scale) => setState(() {
                      _motherImgOffset = o;
                      _motherImgScale  = scale;
                    }),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      height: 48.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kIdCardThemes.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final t   = kIdCardThemes[i];
          final sel = i == _themeIndex;
          return GestureDetector(
            onTap: () => setState(() => _themeIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: sel ? t.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: t.primary,
                  width: sel ? 0 : 1.5,
                ),
                boxShadow: sel
                    ? [BoxShadow(color: t.primary.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Text(
                t.name,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : t.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _theme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _theme.primary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  ADJUSTABLE PHOTO WIDGET
// ═══════════════════════════════════════════════════════════════════════
class _AdjustablePhoto extends StatefulWidget {
  final String?           imageUrl;
  final double            width;
  final double            height;
  final double            borderRadius;
  final Color             borderColor;
  final Color             bgColor;
  final Widget            placeholder;
  final Offset            initialOffset;
  final double            initialScale;
  final void Function(Offset offset, double scale) onChanged;

  const _AdjustablePhoto({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.borderColor,
    required this.bgColor,
    required this.placeholder,
    required this.initialOffset,
    required this.initialScale,
    required this.onChanged,
  });

  @override
  State<_AdjustablePhoto> createState() => _AdjustablePhotoState();
}

class _AdjustablePhotoState extends State<_AdjustablePhoto> {
  late Offset _offset;
  late double _scale;

  Offset? _startFocal;
  Offset? _startOffset;
  double? _startScale;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
    _scale  = widget.initialScale;
  }

  @override
  void didUpdateWidget(_AdjustablePhoto old) {
    super.didUpdateWidget(old);
    if (old.initialOffset != widget.initialOffset) _offset = widget.initialOffset;
    if (old.initialScale  != widget.initialScale)  _scale  = widget.initialScale;
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startFocal  = d.localFocalPoint;
    _startOffset = _offset;
    _startScale  = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_startFocal == null) return;
    final newScale = (_startScale! * d.scale).clamp(0.5, 3.0);
    final delta    = d.localFocalPoint - _startFocal!;
    setState(() {
      _scale  = newScale;
      _offset = _startOffset! + delta;
    });
    widget.onChanged(_offset, _scale);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: 2),
        color: widget.bgColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 2),
        child: GestureDetector(
          onScaleStart: widget.imageUrl != null ? _onScaleStart : null,
          onScaleUpdate: widget.imageUrl != null ? _onScaleUpdate : null,
          child: widget.imageUrl != null
              ? Transform.translate(
            offset: _offset,
            child: Transform.scale(
              scale: _scale,
              child: Image.network(
                widget.imageUrl!,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => widget.placeholder,
              ),
            ),
          )
              : widget.placeholder,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  FRONT CARD
// ═══════════════════════════════════════════════════════════
class _FrontCard extends StatelessWidget {
  final IdCardStudentData student;
  final String            dynamicLogoUrl;
  final IdCardTheme       theme;
  final Offset            imgOffset;
  final double            imgScale;
  final void Function(Offset, double) onAdjust;

  const _FrontCard({
    required this.student,
    required this.dynamicLogoUrl,
    required this.theme,
    required this.imgOffset,
    required this.imgScale,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final logoUrl = dynamicLogoUrl.isNotEmpty
        ? dynamicLogoUrl
        : (student.logoWithName != null
        ? '$_imgBase/Upload/school/${student.logoWithName}'
        : null);

    final studentImgUrl = student.studentPic != null
        ? '$_imgBase${student.studentPic}'
        : null;
    final dob = student.dateOfBirth != null
        ? DateFormat('dd MMM yyyy').format(student.dateOfBirth!)
        : '-';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.primary, t.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: logoUrl != null
                          ? CachedNetworkImage(
                        imageUrl:    logoUrl,
                        fit:         BoxFit.contain,
                        placeholder: (_, __) => Icon(Icons.school, color: t.primary, size: 28),
                        errorWidget: (_, __, ___) => Icon(Icons.school, color: t.primary, size: 28),
                      )
                          : Icon(Icons.school, color: t.primary, size: 28),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    (student.schoolName ?? 'School').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (student.affiliated != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      student.affiliated!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                    ),
                  ],
                  SizedBox(height: 3.h),
                  Text(
                    student.schoolAddress ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  ),
                  SizedBox(height: 2.h),
                  // Fixed: Icon + number only, no extra broken characters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, color: Colors.white70, size: 13),
                      SizedBox(width: 4.w),
                      Text(
                        student.schoolPhone ?? '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ribbon
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5.h),
              color: t.ribbonBg,
              child: Text(
                'STUDENT IDENTITY CARD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: t.ribbonText,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Body
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _AdjustablePhoto(
                        imageUrl:      studentImgUrl,
                        width:         85.w,
                        height:        95.w,
                        borderRadius:  10.r,
                        borderColor:   t.primaryLight,
                        bgColor:       t.ribbonBg,
                        placeholder:   Icon(Icons.person, size: 40.w, color: t.primaryLight),
                        initialOffset: imgOffset,
                        initialScale:  imgScale,
                        onChanged:     onAdjust,
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          student.className ?? '-',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 14.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.studentName ?? '-',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Reg: ${student.registrationNo ?? '-'}',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: t.primaryLight,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 10.h),
                        _infoRow('Father',    student.fatherName, t),
                        _infoRow('Mother',    student.motherName, t),
                        _infoRow('DOB',       dob, t),
                        _infoRow('Blood Grp', student.bloodGroup, t),
                        _infoRow('Section',   '${student.sectionName ?? '-'}', t),
                        if ((student.rollNo ?? '').isNotEmpty)
                          _infoRow('Roll No', student.rollNo, t),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.primary, t.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session: ${student.session ?? '-'}',
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  ),
                  Text(
                    student.schoolEmail ?? '',
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, IdCardTheme t) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              '$label :',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: _textPrimary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  BACK CARD
// ═══════════════════════════════════════════════════════════
class _BackCard extends StatelessWidget {
  final IdCardStudentData student;
  final IdCardTheme       theme;
  final Offset            fatherOffset;
  final double            fatherScale;
  final Offset            motherOffset;
  final double            motherScale;
  final void Function(Offset, double) onFatherAdjust;
  final void Function(Offset, double) onMotherAdjust;

  const _BackCard({
    required this.student,
    required this.theme,
    required this.fatherOffset,
    required this.fatherScale,
    required this.motherOffset,
    required this.motherScale,
    required this.onFatherAdjust,
    required this.onMotherAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final fatherImgUrl = student.fatherPic != null
        ? '$_imgBase${student.fatherPic}'
        : null;
    final motherImgUrl = student.motherPic != null
        ? '$_imgBase${student.motherPic}'
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.primary, t.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                (student.schoolName ?? 'School').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _parentAvatar(
                        fatherImgUrl,
                        student.fatherName ?? '-',
                        Icons.man_outlined,
                        'Father',
                        t,
                        fatherOffset,
                        fatherScale,
                        onFatherAdjust,
                      ),
                      Container(
                          width: 1, height: 80, color: t.ribbonBg),
                      _parentAvatar(
                        motherImgUrl,
                        student.motherName ?? '-',
                        Icons.woman_outlined,
                        'Mother',
                        t,
                        motherOffset,
                        motherScale,
                        onMotherAdjust,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Divider(color: t.ribbonBg, thickness: 1),
                  SizedBox(height: 10.h),

                  _backRow(Icons.phone_in_talk_rounded,    'Phone',     student.phone       ?? '-', t),
                  _backRow(Icons.phone_android_outlined,   'WhatsApp',  student.whatsAppNo  ?? '-', t),
                  _backRow(Icons.emergency_outlined,       'Emergency', student.emergencyNo ?? '-', t),
                  _backRow(Icons.email_outlined,           'Email',     student.email       ?? '-', t),
                  _backRow(Icons.home_outlined,            'Address',   student.address     ?? '-', t),

                  SizedBox(height: 10.h),

                  if ((student.transportUser ?? '').toLowerCase() == 'yes') ...[
                    Divider(color: t.ribbonBg, thickness: 1),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.directions_bus_outlined, size: 14, color: t.primaryLight),
                        SizedBox(width: 6.w),
                        Text(
                          'Transport Details',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: t.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    _backRow(Icons.route_outlined, 'Route No', student.routeNo     ?? '-', t),
                    _backRow(Icons.place_outlined, 'Stop',     student.pickupPoint ?? '-', t),
                    SizedBox(height: 4.h),
                  ],

                  SizedBox(height: 10.h),
                  Divider(color: t.ribbonBg, thickness: 1),
                  SizedBox(height: 8.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: t.ribbonBg,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'If found, please return to the school.\n'
                          '${student.schoolName ?? ''} | ${student.schoolAddress ?? ''}\n'
                          '📞 ${student.schoolPhone ?? ''}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: _textSecondary,
                          height: 1.6),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: t.footerBg,
              child: Text(
                'Authorised Signature ____________________',
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.white70, fontSize: 10.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parentAvatar(
      String? imgUrl,
      String name,
      IconData fallback,
      String label,
      IdCardTheme t,
      Offset offset,
      double scale,
      void Function(Offset, double) onChanged,
      ) {
    return Column(
      children: [
        _AdjustablePhoto(
          imageUrl:      imgUrl,
          width:         60.w,
          height:        65.w,
          borderRadius:  10.r,
          borderColor:   t.primaryLight,
          bgColor:       t.ribbonBg,
          placeholder:   Icon(fallback, size: 28.w, color: t.primaryLight),
          initialOffset: offset,
          initialScale:  scale,
          onChanged:     onChanged,
        ),
        SizedBox(height: 4.h),
        // Text(label,
        //     style: TextStyle(
        //         fontSize: 9.sp,
        //         color: t.primaryLight,
        //         fontWeight: FontWeight.w600)),
        // SizedBox(height: 2.h),
        SizedBox(
          width: 110.w,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: _textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _backRow(IconData icon, String label, String value, IdCardTheme t) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: t.primaryLight),
          SizedBox(width: 6.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '$label :',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: _textPrimary,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}