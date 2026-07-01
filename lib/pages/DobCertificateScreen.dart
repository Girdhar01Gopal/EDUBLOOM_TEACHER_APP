// ============================================================
// dob_certificate_screen.dart
// ============================================================

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/DobCertificateController.dart';
import '../controller/home_page_controller.dart'; // ← DashboardScreenController
import '../models/DOB print certificacte model.dart';
import '../models/student_model.dart';
import '../res/app_url.dart'; // ← AppUrl.dashurl

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);

// ═══════════════════════════════════════════════════════════════
//  Certificate Theme Model
// ═══════════════════════════════════════════════════════════════
class _CertTheme {
  final Color primaryColor;
  final Color lightColor;
  final Color veryLightColor;
  final String label;

  const _CertTheme({
    required this.primaryColor,
    required this.lightColor,
    required this.veryLightColor,
    required this.label,
  });
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 1 — Student List  (word to word same)
// ═══════════════════════════════════════════════════════════════
class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  StudentListController get ctrl {
    if (!Get.isRegistered<StudentListController>()) {
      Get.put(StudentListController());
    }
    return Get.find<StudentListController>();
  }

  @override
  Widget build(BuildContext context) {
    ctrl;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: kAxisMaroon,
        title: const Text(
          '📚 DOB Certificate',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: ctrl.fetchStudents,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: TextField(
                onChanged: ctrl.searchStudents,
                decoration: InputDecoration(
                  hintText:
                  'Search by Name / Reg No / Mobile / Class',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Colors.grey),
                  prefixIcon:
                  const Icon(Icons.search, color: kAxisMaroon),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),

            // ── List ────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (ctrl.students.isEmpty) {
                  return const Center(
                    child: Text('No students found.',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 15)),
                  );
                }

                return Stack(
                  children: [
                    // ── DataTable ─────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                          WidgetStateProperty.all(
                              kAxisMaroon.withOpacity(0.08)),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kAxisMaroon,
                            fontSize: 13,
                          ),
                          dataTextStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87),
                          dividerThickness: 0.5,
                          columnSpacing: 14,
                          columns: const [
                            DataColumn(label: Text('S.No')),
                            DataColumn(label: Text('Reg No')),
                            DataColumn(label: Text('Name')),
                            DataColumn(
                                label: Text('Father Name')),
                            DataColumn(label: Text('Class')),
                            DataColumn(label: Text('Section')),
                            DataColumn(label: Text('Mobile')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: List.generate(
                              ctrl.students.length, (i) {
                            final s = ctrl.students[i];
                            return DataRow(
                              color:
                              WidgetStateProperty.resolveWith(
                                    (states) => i % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade50,
                              ),
                              cells: [
                                DataCell(Text('${i + 1}')),
                                DataCell(Text(
                                  s.registrationNo ?? '-',
                                  style: const TextStyle(
                                      fontSize: 11),
                                )),
                                DataCell(Text(
                                    s.studentName ?? '-')),
                                DataCell(Text(
                                    s.fatherName ?? '-')),
                                DataCell(
                                    Text(s.className ?? '-')),
                                DataCell(
                                    Text(s.sectionName ?? '-')),
                                DataCell(Text(s.phone ?? '-')),
                                DataCell(
                                  Obx(() =>
                                  ctrl.isCertLoading.value
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                    CircularProgressIndicator(
                                        strokeWidth:
                                        2),
                                  )
                                      : ElevatedButton.icon(
                                    onPressed: () =>
                                        _onPrint(s),
                                    icon: const Icon(
                                        Icons.print,
                                        size: 14,
                                        color: Colors
                                            .white),
                                    label: const Text(
                                        'Print',
                                        style: TextStyle(
                                            color: Colors
                                                .white,
                                            fontSize:
                                            12)),
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor:
                                      Colors.orange
                                          .shade600,
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                          horizontal:
                                          10,
                                          vertical:
                                          6),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            6),
                                      ),
                                      minimumSize:
                                      const Size(
                                          70, 32),
                                    ),
                                  )),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),

                    // ── Certificate fetch overlay ──────────────
                    Obx(() => ctrl.isCertLoading.value
                        ? Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 24),
                            child: Column(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                    color: kAxisMaroon),
                                SizedBox(height: 14),
                                Text(
                                    'Fetching Certificate…',
                                    style: TextStyle(
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                        : const SizedBox.shrink()),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPrint(StudentData student) async {
    if (ctrl.isCertLoading.value) return;
    final certData = await ctrl.fetchDobCertificate(student);
    if (certData != null) {
      Get.to(() => DobCertificateViewScreen(certData: certData));
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  Widget: Student Avatar  (same)
// ═══════════════════════════════════════════════════════════════
class _StudentAvatar extends StatelessWidget {
  final String url;
  const _StudentAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: kAxisMaroon.withOpacity(0.15),
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: kAxisMaroon.withOpacity(0.15),
      child: const Icon(Icons.person,
          size: 18, color: kAxisMaroon),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 2 — DOB Certificate View + Swipeable Themes
// ═══════════════════════════════════════════════════════════════
class DobCertificateViewScreen extends StatefulWidget {
  final PrintCertificateData certData;
  const DobCertificateViewScreen(
      {super.key, required this.certData});

  @override
  State<DobCertificateViewScreen> createState() =>
      _DobCertificateViewScreenState();
}

class _DobCertificateViewScreenState
    extends State<DobCertificateViewScreen> {
  // ── Themes ───────────────────────────────────────────────────
  static const List<_CertTheme> _themes = [
    _CertTheme(
      primaryColor: Color(0xFFE65100),
      lightColor: Color(0xFFFFCCBC),
      veryLightColor: Color(0xFFFFF3E0),
      label: 'Orange',
    ),
    _CertTheme(
      primaryColor: Color(0xFFF9A825),
      lightColor: Color(0xFFFFE082),
      veryLightColor: Color(0xFFFFFDE7),
      label: 'Yellow',
    ),
    _CertTheme(
      primaryColor: Color(0xFF2C3E50),
      lightColor: Color(0xFFB0BEC5),
      veryLightColor: Color(0xFFECEFF1),
      label: 'Navy',
    ),
    _CertTheme(
      primaryColor: Color(0xFF00695C),
      lightColor: Color(0xFF80CBC4),
      veryLightColor: Color(0xFFE0F2F1),
      label: 'Teal',
    ),
    _CertTheme(
      primaryColor: Color(0xFF4527A0),
      lightColor: Color(0xFFCE93D8),
      veryLightColor: Color(0xFFF3E5F5),
      label: 'Purple',
    ),
    _CertTheme(
      primaryColor: Color(0xFF1565C0),
      lightColor: Color(0xFF90CAF9),
      veryLightColor: Color(0xFFE3F2FD),
      label: 'Blue',
    ),
    _CertTheme(
      primaryColor: Color(0xFFC62828),
      lightColor: Color(0xFFEF9A9A),
      veryLightColor: Color(0xFFFFEBEE),
      label: 'Red',
    ),

    // ── Black & White theme ──────────────────────────────────
    _CertTheme(
      primaryColor: Color(0xFF000000),
      lightColor: Color(0xFF9E9E9E),
      veryLightColor: Color(0xFFFFFFFF),
      label: 'Black & White',
    ),
  ];

  int _selectedThemeIndex = 0;
  late final PageController _pageController;

  // One RepaintBoundary key per theme page — 8 themes
  final List<GlobalKey> _repaintKeys =
  List.generate(8, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Dynamic school logo URL from DashboardScreenController ───
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

  // ── Capture PNG bytes for selected theme ─────────────────────
  Future<List<int>?> _captureBytes() async {
    try {
      final boundary = _repaintKeys[_selectedThemeIndex]
          .currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image =
      await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  // ── Print ────────────────────────────────────────────────────
  Future<void> _printCertificate() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final bytes = await _captureBytes();
      Get.back();
      if (bytes == null) {
        Get.snackbar('Error', 'Could not capture certificate.');
        return;
      }
      await Printing.layoutPdf(
        onLayout: (_) async {
          final doc =
          await _pngBytesToPdf(Uint8List.fromList(bytes));
          return doc;
        },
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Print failed: $e');
    }
  }

  // helper: wrap PNG in minimal PDF
  Future<Uint8List> _pngBytesToPdf(Uint8List pngBytes) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(pngBytes);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(image, fit: pw.BoxFit.contain),
      ),
    );
    return Uint8List.fromList(await pdf.save());
  }

  // ── Share ────────────────────────────────────────────────────
  Future<void> _shareCertificate() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final bytes = await _captureBytes();
      Get.back();
      if (bytes == null) {
        Get.snackbar('Error', 'Could not capture certificate.');
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final safeName =
      (widget.certData.studentName ?? 'student')
          .replaceAll(' ', '_');
      final file =
      File('${tempDir.path}/dob_cert_$safeName.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
        'DOB Certificate – ${widget.certData.studentName ?? ''}',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Share error: $e');
      Get.snackbar(
        'Error',
        'Certificate not shared. Please retry.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Theme Dot Indicators ─────────────────────────────────────
  Widget _buildThemeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_themes.length, (i) {
        final isSelected = i == _selectedThemeIndex;
        final isBW = _themes[i].label == 'Black & White';
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isSelected ? 28 : 12,
            height: 10,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isBW ? Colors.black : _themes[i].primaryColor)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(
                  color: isBW
                      ? Colors.black
                      : _themes[i].primaryColor,
                  width: 1.5)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ── Logo Widget (not circle, just rounded rect) ──────────────
  Widget _buildLogo(_CertTheme theme) {
    final isBW = theme.label == 'Black & White';
    final dynamicUrl = _dynamicSchoolLogoUrl;

    if (dynamicUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          dynamicUrl,
          height: 80,
          width: 80,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              _buildCertDataLogo(theme, isBW),
        ),
      );
    }
    return _buildCertDataLogo(theme, isBW);
  }

  Widget _buildCertDataLogo(_CertTheme theme, bool isBW) {
    final path = widget.certData.logoWithName ??
        widget.certData.logo ??
        '';
    final logoUrl = StudentListController.buildImageUrl(path);
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          logoUrl,
          height: 80,
          width: 80,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.school,
            size: 54,
            color: isBW ? Colors.black : theme.primaryColor,
          ),
        ),
      );
    }
    return Icon(
      Icons.school,
      size: 54,
      color: isBW ? Colors.black : theme.primaryColor,
    );
  }

  // ── Certificate Card ─────────────────────────────────────────
  Widget _buildCertCard(_CertTheme theme) {
    final c = widget.certData;
    final isBW = theme.label == 'Black & White';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 17, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── School Header — centered: logo → name → address → contact → email ──
          Center(child: _buildLogo(theme)),
          const SizedBox(height: 1),
          Center(
            child: Text(
              c.schoolName ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isBW ? Colors.black : theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if ((c.schoolAddress ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                c.schoolAddress!.trim(),
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 3),
          Center(
            child: Text(
              'Contact: ${c.schoolPhone ?? '-'}',
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 3),
          Center(
            child: Text(
              'Email: ${c.schoolEmail ?? '-'}',
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          if ((c.schoolWebsite ?? '').isNotEmpty) ...[
            const SizedBox(height: 3),
            Center(
              child: Text(
                'Web: ${c.schoolWebsite}',
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 5),
          Divider(
            color: isBW ? Colors.black : theme.lightColor,
            thickness: isBW ? 1.5 : 1,
          ),

          // ── DOB CERTIFICATE title below divider, centered ──
          const SizedBox(height: 7),
          Center(
            child: Text(
              'DOB CERTIFICATE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isBW ? Colors.black : theme.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Cert No + Issued On ─────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _richLabel(
                  'Certificate No: ', c.certificateNo ?? '-', theme),
              const SizedBox(height: 6),
              _richLabel(
                  'Issued On: ',
                  PrintCertificateData.formatDate(c.issuedOndate),
                  theme),
            ],
          ),
          const SizedBox(height: 16),

          // ── Info Table ──────────────────────────────────────
          _buildInfoTable(theme),
          const SizedBox(height: 20),

          // ── Footer ─────────────────────────────────────────
          Text(
            'This certificate is issued by '
                '${c.schoolName ?? 'the school'} '
                'to validate the birth of the above-named child.',
            style: TextStyle(
              fontSize: 13,
              color: isBW ? Colors.black87 : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 28),
          const Text('Signature: ____________________',
              style: TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 6),
          Text(
            'Authorized by: ${c.schoolName ?? ''}',
            style: const TextStyle(
                fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ── Rich Label ───────────────────────────────────────────────
  Widget _richLabel(
      String label, String value, _CertTheme theme) {
    final isBW = theme.label == 'Black & White';
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: label,
          style: TextStyle(
            color: isBW ? Colors.black : theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(
              color: Colors.black87, fontSize: 13),
        ),
      ]),
    );
  }

  // ── Info Table ───────────────────────────────────────────────
  Widget _buildInfoTable(_CertTheme theme) {
    final c = widget.certData;
    final isBW = theme.label == 'Black & White';

    final rows = [
      ["Student Name", c.studentName ?? '-'],
      [
        "Date of Birth",
        PrintCertificateData.formatDate(c.dateOfBirth)
      ],
      ["Place of Birth", c.address ?? '-'],
      ["Father Name", c.fatherName ?? '-'],
      ["Mother Name", c.motherName ?? '-'],
      ["Gender", c.gender ?? '-'],
      ["Blood Group", c.bloodGroup ?? '-'],
      ["Religion", c.religion ?? '-'],
      ["Class", c.className ?? '-'],
      ["Section", c.sectionName ?? '-'],
      ["Registration No", c.registrationNo ?? '-'],
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isBW ? Colors.black : theme.lightColor,
          width: isBW ? 1.2 : 1.0,
        ),
      ),
      child: Table(
        border: TableBorder.all(
          color: isBW ? Colors.black54 : theme.lightColor,
          width: 0.8,
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.6),
          1: FlexColumnWidth(2.0),
        },
        children: rows.map((row) {
          return TableRow(
            decoration: BoxDecoration(
              color: isBW ? Colors.white : theme.veryLightColor,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 9),
                child: Text(
                  row[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isBW ? Colors.black : Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 9),
                child: Text(
                  row[1],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Main Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final activeTheme = _themes[_selectedThemeIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: kAxisMaroon,
        title: const Text(
          'DOB Certificate',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
          const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon:
            const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share',
            onPressed: _shareCertificate,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Swipe hint ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Swipe to change theme  •  ${activeTheme.label}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // ── Dot indicators ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _buildThemeDots(),
          ),

          // ── Swipeable certificate cards ─────────────────────
          Expanded(
            child: RefreshIndicator(
              color: kAxisMaroon,
              onRefresh: () async {
                await Future.delayed(
                    const Duration(milliseconds: 400));
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _themes.length,
                onPageChanged: (index) {
                  setState(() => _selectedThemeIndex = index);
                },
                itemBuilder: (context, index) {
                  final theme = _themes[index];
                  final isSelected =
                      index == _selectedThemeIndex;
                  final isBW = theme.label == 'Black & White';
                  return SingleChildScrollView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 16),
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isBW
                              ? Colors.black
                              : theme.primaryColor)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? (isBW
                                ? Colors.black
                                .withOpacity(0.20)
                                : theme.primaryColor
                                .withOpacity(0.25))
                                : Colors.black
                                .withOpacity(0.06),
                            blurRadius:
                            isSelected ? 18 : 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: RepaintBoundary(
                        key: _repaintKeys[index],
                        child: _buildCertCard(theme),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Bottom Buttons ──────────────────────────────────
          Container(
            color: Colors.white,
            padding:
            const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                // Print
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _printCertificate,
                    icon: const Icon(Icons.print,
                        color: Colors.white, size: 20),
                    label: const Text(
                      'Print Certificate',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      activeTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Share
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _shareCertificate,
                    icon: Icon(Icons.share,
                        color: activeTheme.primaryColor,
                        size: 20),
                    label: Text(
                      'Share Certificate',
                      style: TextStyle(
                          color: activeTheme.primaryColor,
                          fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: activeTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8)),
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