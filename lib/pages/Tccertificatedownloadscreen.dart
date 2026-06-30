import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/home_page_controller.dart';
import '../models/DownloadTcResponse.dart';
import '../res/app_url.dart';

// ── Certificate Theme Model ──────────────────────────────────
class _CertTheme {
  final Color headerColor;
  final Color boldTextColor;
  final String label;

  const _CertTheme({
    required this.headerColor,
    required this.boldTextColor,
    required this.label,
  });
}

class TcCertificateDownloadScreen extends StatefulWidget {
  final int studentId;
  final String schoolId;
  final String session;

  const TcCertificateDownloadScreen({
    Key? key,
    required this.studentId,
    required this.schoolId,
    required this.session,
  }) : super(key: key);

  @override
  State<TcCertificateDownloadScreen> createState() =>
      _TcCertificateDownloadScreenState();
}

class _TcCertificateDownloadScreenState
    extends State<TcCertificateDownloadScreen> {
  bool isLoading = true;
  String? errorMsg;
  DownloadTcModel? tcData;

  // ── Swipeable Themes ─────────────────────────────────────────
  static const List<_CertTheme> _themes = [
    _CertTheme(
      headerColor: Color(0xFF2C3E50),
      boldTextColor: Color(0xFF1A5276),
      label: 'Navy',
    ),
    _CertTheme(
      headerColor: Color(0xFF00695C),
      boldTextColor: Color(0xFF004D40),
      label: 'Teal',
    ),
    _CertTheme(
      headerColor: Color(0xFF4527A0),
      boldTextColor: Color(0xFF311B92),
      label: 'Purple',
    ),
    _CertTheme(
      headerColor: Color(0xFF1565C0),
      boldTextColor: Color(0xFF0D47A1),
      label: 'Blue',
    ),
    _CertTheme(
      headerColor: Color(0xFFC62828),
      boldTextColor: Color(0xFFB71C1C),
      label: 'Red',
    ),
    _CertTheme(
      headerColor: Color(0xFFE65100),
      boldTextColor: Color(0xFFBF360C),
      label: 'Orange',
    ),
    _CertTheme(
      headerColor: Color(0xFFF9A825),
      boldTextColor: Color(0xFFF57F17),
      label: 'Yellow',
    ),
  ];

  int _selectedThemeIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchTcDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Dynamic school logo URL ──────────────────────────────────
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

  // ── Helper: Color → PdfColor ─────────────────────────────────
  PdfColor _toPdfColor(Color c) => PdfColor(
    c.red / 255,
    c.green / 255,
    c.blue / 255,
  );

  // ── Fetch logo bytes for PDF ─────────────────────────────────
  Future<Uint8List?> _fetchLogoBytes() async {
    final logoUrl = _dynamicSchoolLogoUrl;
    if (logoUrl.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (_) {}
    return null;
  }

  // ── API Fetch ────────────────────────────────────────────────
  Future<void> _fetchTcDetails() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final url =
          '${AppUrl.base_url}api/SchoolApp/GetTcStudentDetails'
          '/${widget.studentId}/${widget.schoolId}/${widget.session}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parsed = DownloadTcResponse.fromJson(jsonData);

        if (parsed.isSuccess && parsed.data.isNotEmpty) {
          setState(() {
            tcData = parsed.data.first;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMsg = parsed.messages.isNotEmpty
                ? parsed.messages
                : 'No TC data found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMsg = 'Failed to load TC. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // ── Build PDF with selected theme + logo ────────────────────
  Future<Uint8List?> _buildPdf() async {
    if (tcData == null) return null;
    final tc = tcData!;
    final theme = _themes[_selectedThemeIndex];
    final pdf = pw.Document();

    // Fetch logo bytes
    final logoBytes = await _fetchLogoBytes();
    pw.MemoryImage? logoImage;
    if (logoBytes != null) {
      logoImage = pw.MemoryImage(logoBytes);
    }

    final schoolInfoParts = <String>[
      if (tc.address.trim().isNotEmpty) tc.address.trim(),
      if (tc.state.trim().isNotEmpty) tc.state.trim(),
    ];
    final schoolInfo = schoolInfoParts.join(', ');

    final contactParts = <String>[
      if ((tc.phone ?? '').trim().isNotEmpty) 'Ph: ${tc.phone!.trim()}',
      if (tc.email.trim().isNotEmpty) tc.email.trim(),
    ];
    final contactInfo = contactParts.join('   |   ');

    final headerPdfColor = _toPdfColor(theme.headerColor);
    final boldPdfColor = _toPdfColor(theme.boldTextColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header Card ──────────────────────────────────
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                decoration: pw.BoxDecoration(
                  color: headerPdfColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Logo centered at top
                    if (logoImage != null) ...[
                      pw.Container(
                        width: 72,
                        height: 72,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.ClipOval(
                          child: pw.Image(logoImage,
                              width: 72, height: 72, fit: pw.BoxFit.contain),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                    ],
                    // School Name
                    pw.Text(
                      tc.schoolName,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    // Address
                    if (schoolInfo.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        schoolInfo,
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                    // Email / Phone
                    if (contactInfo.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        contactInfo,
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // ── TRANSFER CERTIFICATE title below card ────────
              pw.Center(
                child: pw.Text(
                  'TRANSFER CERTIFICATE',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: boldPdfColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // ── Paragraph 1 ──────────────────────────────────
              pw.RichText(
                text: pw.TextSpan(
                  style: const pw.TextStyle(
                      fontSize: 13, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(text: 'This is to certify that '),
                    pw.TextSpan(
                      text: tc.studentName.toUpperCase(),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: boldPdfColor),
                    ),
                    const pw.TextSpan(text: ', son/daughter '),
                    pw.TextSpan(
                      text: tc.fatherName.toUpperCase(),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: boldPdfColor),
                    ),
                    const pw.TextSpan(text: ', from Class '),
                    pw.TextSpan(
                      text: tc.className.toUpperCase(),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: boldPdfColor),
                    ),
                    const pw.TextSpan(text: ', bearing Registration No. '),
                    pw.TextSpan(
                      text: tc.registrationNo,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: boldPdfColor),
                    ),
                    const pw.TextSpan(
                        text:
                        ', has completed his/her course and is granted a Transfer Certificate.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // ── Paragraph 2 ──────────────────────────────────
              pw.RichText(
                text: pw.TextSpan(
                  style: const pw.TextStyle(
                      fontSize: 13, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(text: 'The student left the school on '),
                    pw.TextSpan(
                      text: tc.issue22,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: boldPdfColor),
                    ),
                    const pw.TextSpan(text: ' for '),
                    pw.TextSpan(
                      text: tc.reasons23,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: boldPdfColor),
                    ),
                    const pw.TextSpan(text: '.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // ── Paragraph 3 ──────────────────────────────────
              pw.Text(
                'All dues have been cleared up to the date of leaving.',
                style: const pw.TextStyle(fontSize: 13),
              ),
              pw.SizedBox(height: 32),

              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 24),

              // ── Signatures ───────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Class Teacher',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 13)),
                      pw.SizedBox(height: 6),
                      pw.Text('Signature: ____________',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Head of School',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 13)),
                      pw.SizedBox(height: 6),
                      pw.Text('Signature: ____________',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ── Print ────────────────────────────────────────────────────
  Future<void> _printCertificate() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final pdfBytes = await _buildPdf();
      Get.back();
      if (pdfBytes == null) {
        Get.snackbar('Error', 'Could not generate PDF for printing.');
        return;
      }
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Print failed: $e');
    }
  }

  // ── Share PDF ────────────────────────────────────────────────
  Future<void> _sharePdf() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final pdfBytes = await _buildPdf();
      if (pdfBytes == null) {
        Get.back();
        Get.snackbar('Error', 'Could not generate PDF.');
        return;
      }
      final dir = await getTemporaryDirectory();
      final fileName = 'TC_${tcData?.studentName ?? 'certificate'}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      Get.back();
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
        'Transfer Certificate - ${tcData?.studentName ?? ''} | ${tcData?.schoolName ?? ''}',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Share failed: $e');
    }
  }

  // ── School Logo Widget ───────────────────────────────────────
  Widget _buildSchoolLogoAvatar({double size = 72}) {
    final logoUrl = _dynamicSchoolLogoUrl;
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: logoUrl.isNotEmpty
            ? Image.network(
          logoUrl,
          height: size,
          width: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.school,
            size: size * 0.5,
            color: Colors.grey,
          ),
        )
            : Icon(
          Icons.school,
          size: size * 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ── Certificate Card UI ──────────────────────────────────────
  Widget _buildCertificateWidget(DownloadTcModel tc, _CertTheme theme) {
    final schoolInfoParts = <String>[
      if (tc.address.trim().isNotEmpty) tc.address.trim(),
      if (tc.state.trim().isNotEmpty) tc.state.trim(),
    ];
    final schoolInfo = schoolInfoParts.join(', ');

    final contactParts = <String>[
      if ((tc.phone ?? '').trim().isNotEmpty) 'Ph: ${tc.phone!.trim()}',
      if (tc.email.trim().isNotEmpty) tc.email.trim(),
    ];
    final contactInfo = contactParts.join('   |   ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header Card ───────────────────────────────────────
        Container(
          width: double.infinity,
          padding:
          EdgeInsets.symmetric(vertical: 26.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: theme.headerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Logo centered at top
              _buildSchoolLogoAvatar(size: 72.w),
              SizedBox(height: 12.h),

              // School Name
              Text(
                tc.schoolName,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              // Address
              if (schoolInfo.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  schoolInfo,
                  style:
                  TextStyle(fontSize: 11.sp, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],

              // Email / Phone
              if (contactInfo.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  contactInfo,
                  style:
                  TextStyle(fontSize: 11.sp, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        // ── TRANSFER CERTIFICATE label below card ─────────────
        SizedBox(height: 14.h),
        Center(
          child: Text(
            'TRANSFER CERTIFICATE',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: theme.boldTextColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // ── Paragraph 1 — names/class UPPERCASE ──────────────
        RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 14.sp, color: Colors.black, height: 1.65),
            children: [
              const TextSpan(text: 'This is to certify that '),
              TextSpan(
                text: tc.studentName.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor),
              ),
              const TextSpan(text: ', son/daughter '),
              TextSpan(
                text: tc.fatherName.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor),
              ),
              const TextSpan(text: ', from Class '),
              TextSpan(
                text: tc.className.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor),
              ),
              const TextSpan(text: ', bearing Admission No. '),
              TextSpan(
                text: tc.registrationNo,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor),
              ),
              const TextSpan(
                  text:
                  ', has completed his/her course and is granted a Transfer Certificate.'),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // ── Paragraph 2 ──────────────────────────────────────
        RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 14.sp, color: Colors.black, height: 1.65),
            children: [
              const TextSpan(text: 'The student left the school on '),
              TextSpan(
                text: tc.issue22,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor),
              ),
              const TextSpan(text: ' for '),
              TextSpan(
                text: tc.reasons23,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // ── Paragraph 3 ──────────────────────────────────────
        Text(
          'All dues have been cleared up to the date of leaving.',
          style: TextStyle(
              fontSize: 14.sp, color: Colors.black, height: 1.65),
        ),
        SizedBox(height: 28.h),

        Divider(color: Colors.grey.shade400, thickness: 1),
        SizedBox(height: 20.h),

        // ── Signatures ───────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Teacher',
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Signature: ____________',
                  style:
                  TextStyle(fontSize: 12.sp, color: Colors.black87),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Head of School',
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Signature: ____________',
                  style:
                  TextStyle(fontSize: 12.sp, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Theme Dot Indicator ──────────────────────────────────────
  Widget _buildThemeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_themes.length, (i) {
        final isSelected = i == _selectedThemeIndex;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            width: isSelected ? 28.w : 12.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? _themes[i].headerColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(
                  color: _themes[i].headerColor, width: 1.5)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ── Main Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final activeTheme = _themes[_selectedThemeIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Transfer Certificate',
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share PDF',
            onPressed: isLoading || tcData == null ? null : _sharePdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.red.shade400, size: 64),
              SizedBox(height: 14.h),
              Text(
                errorMsg!,
                style: const TextStyle(
                    color: Colors.red, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: _fetchTcDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          // ── Swipe hint label ──────────────────────
          Padding(
            padding:
            EdgeInsets.only(top: 12.h, bottom: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe,
                    size: 16, color: Colors.grey.shade500),
                SizedBox(width: 4.w),
                Text(
                  'Swipe to change theme  •  ${activeTheme.label}',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // ── Theme dot indicators ──────────────────
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: _buildThemeDots(),
          ),

          // ── Swipeable certificate cards ───────────
          Expanded(
            child: RefreshIndicator(
              color: Colors.teal.shade800,
              onRefresh: _fetchTcDetails,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _themes.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedThemeIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final theme = _themes[index];
                  final isSelected =
                      index == _selectedThemeIndex;
                  return SingleChildScrollView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                        16.w, 8.h, 16.w, 16.h),
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                            color: theme.headerColor,
                            width: 2.5)
                            : Border.all(
                            color: Colors.transparent,
                            width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? theme.headerColor
                                .withOpacity(0.25)
                                : Colors.black
                                .withOpacity(0.06),
                            blurRadius: isSelected ? 18 : 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20.w),
                      child: _buildCertificateWidget(
                          tcData!, theme),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Bottom Buttons ────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                16.w, 12.h, 16.w, 20.h),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _printCertificate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeTheme.headerColor,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Print Certificate',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sharePdf,
                    icon: Icon(Icons.picture_as_pdf,
                        color: activeTheme.headerColor,
                        size: 20),
                    label: Text(
                      'Share as PDF',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: activeTheme.headerColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: activeTheme.headerColor),
                      padding: EdgeInsets.symmetric(
                          vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}