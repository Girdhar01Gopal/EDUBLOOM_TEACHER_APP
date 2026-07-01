import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controller/stationary_fee_print_controller.dart';
import '../controller/home_page_controller.dart';   // ← DashboardScreenController
import '../res/app_url.dart';                        // ← AppUrl.dashurl

class StationaryFeePrintScreen extends GetView<StationaryFeePrintController> {
  const StationaryFeePrintScreen({super.key});

  // ── Dynamic school logo URL — same as AppDrawer ──────────────
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

  // ── School Logo Widget — white circle avatar ─────────────────
  Widget _buildSchoolLogoAvatar() {
    final logoUrl = _dynamicSchoolLogoUrl;
    return Container(
      height: 48,
      width: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: logoUrl.isNotEmpty
            ? Image.network(
          logoUrl,
          height: 48,
          width: 48,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.school,
            color: const Color(0xFF97144D),
            size: 30,
          ),
        )
            : const Icon(Icons.school, color: const Color(0xFF97144D), size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7ECF0),
      appBar: AppBar(
        title: const Text(
          '🧾 Stationary Receipt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6E0F38),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 3,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: const Color(0xFF97144D)),
          );
        }

        if (controller.printItems.isEmpty) {
          return const Center(
            child: Text(
              'No receipt data found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  _buildCopy(context, copyLabel: 'Parents Copy'),
                  const SizedBox(height: 28),
                  _buildCopy(context, copyLabel: 'School Copy'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── one receipt copy ──────────────────────────────────────
  Widget _buildCopy(BuildContext context, {required String copyLabel}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF97144D).withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3D9E3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReceiptHeader(context, copyLabel),
          _buildSchoolInfoSection(),
          _buildReceiptBanner(),
          _buildInfoGrid(),
          _buildProductTable(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── gradient header — tap badge to print ─────────────────
  Widget _buildReceiptHeader(BuildContext context, String copyLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6E0F38), const Color(0xFFC24A79)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── School logo (dynamic) ─────────────────────────
          _buildSchoolLogoAvatar(),

          // ── tappable print badge ──────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _printReceipt(context, copyLabel),
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.print_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      copyLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── school info ───────────────────────────────────────────
  Widget _buildSchoolInfoSection() {
    final school  = controller.schoolDetails.value;
    final name    = school?.schoolName    ?? '';
    final address = school?.schoolAddress ?? '';
    final email   = school?.schoolEmailID ?? '';
    final phone   = school?.displayPhone  ?? '';

    final contactParts = <String>[];
    if (phone.isNotEmpty) contactParts.add('Phone: $phone');
    if (email.isNotEmpty) contactParts.add('Email: $email');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: const Color(0xffF9EBF0),
      child: Column(
        children: [
          if (name.isNotEmpty)
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff6E0F38),
                letterSpacing: 0.5,
              ),
            ),
          if (contactParts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                contactParts.join('  |  '),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: const Color(0xFF97144D)),
              ),
            ),
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                address,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  // ── PRODUCT RECEIPT banner ────────────────────────────────
  Widget _buildReceiptBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF97144D), const Color(0xFFB0295F)],
        ),
      ),
      child: const Text(
        'PRODUCT RECEIPT',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // ── info grid ─────────────────────────────────────────────
  Widget _buildInfoGrid() {
    final rows = [
      ['Receipt No',       controller.receiptNumber],
      ['Payment Date',     controller.displayPayDate],
      ['Name',             controller.studentName],
      ['Registration No.', controller.registrationNum],
      ['Parents Name',     controller.fatherName],
      ['Academic Year',    controller.academicYear],
      ['Class/Sec',        controller.classSection],
      ['Payment Mode',     controller.paymentMode],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final isWide = constraints.maxWidth > 500;
          if (isWide) {
            final left  = [rows[0], rows[2], rows[4], rows[6]];
            final right = [rows[1], rows[3], rows[5], rows[7]];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _infoColumn(left)),
                const SizedBox(width: 12),
                Expanded(child: _infoColumn(right)),
              ],
            );
          }
          return _infoColumn(rows);
        },
      ),
    );
  }

  Widget _infoColumn(List<List<String>> rows) {
    return Column(
      children: rows
          .map(
            (r) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  r[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xff6E0F38),
                  ),
                ),
              ),
              const Text(
                ':  ',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: const Color(0xFF97144D)),
              ),
              Expanded(
                child: Text(
                  r[1],
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }

  // ── product table ─────────────────────────────────────────
  Widget _buildProductTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          border: TableBorder.all(
            color: const Color(0xFFF3D9E3),
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFAE1B5C), const Color(0xFFC24A79)],
                ),
              ),
              children: const [
                _TableHeader(text: 'Product'),
                _TableHeader(text: 'Quantity'),
                _TableHeader(text: 'Total Amount'),
              ],
            ),
            ...controller.printItems.map(
                  (item) => TableRow(
                decoration: BoxDecoration(
                  color: controller.printItems.indexOf(item).isEven
                      ? const Color(0xffF9EBF0)
                      : Colors.white,
                ),
                children: [
                  _TableCell(text: item.product),
                  _TableCell(text: '${item.quantity}'),
                  _TableCell(
                    text: '₹ ${item.amount}',
                    isBold: true,
                    color: const Color(0xFF6E0F38),
                  ),
                ],
              ),
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.amber.shade50),
              children: [
                const _TableCell(text: ''),
                const _TableCell(
                  text: 'Total',
                  isBold: true,
                  color: Color(0xff6E0F38),
                ),
                _TableCell(
                  text: '₹ ${controller.totalAmount}',
                  isBold: true,
                  color: const Color(0xFF4A0A26),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    final schoolName = controller.schoolDetails.value?.schoolName ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 1, width: 160, color: const Color(0xFFD98FAE)),
              const SizedBox(height: 4),
              if (schoolName.isNotEmpty)
                Text(
                  'For $schoolName',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF97144D),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 4),
              const Text(
                'Authorized Signatory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff6E0F38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  PRINT — opens system print dialog for the tapped copy
  // ══════════════════════════════════════════════════════════
  Future<void> _printReceipt(
      BuildContext context, String copyLabel) async {
    final school   = controller.schoolDetails.value;
    final logoUrl  = _dynamicSchoolLogoUrl;

    // Try to fetch logo bytes for PDF
    pw.MemoryImage? pdfLogoImage;
    if (logoUrl.isNotEmpty) {
      try {
        final netImg = await networkImage(logoUrl);
        pdfLogoImage = netImg as pw.MemoryImage?;
      } catch (_) {
        pdfLogoImage = null;
      }
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => _buildPdfPage(copyLabel, school, pdfLogoImage),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Stationary_Receipt_${controller.receiptNumber}_$copyLabel',
    );
  }

  // ── PDF page content ──────────────────────────────────────
  pw.Widget _buildPdfPage(
      String copyLabel, dynamic school, pw.MemoryImage? logoImage) {
    final teal     = PdfColor.fromHex('#97144D');
    final tealBg   = PdfColor.fromHex('#F3D9E3');
    final tealLine = PdfColor.fromHex('#E3A9C0');
    final amber    = PdfColor.fromHex('#F59E0B');
    final dark     = PdfColor.fromHex('#6E0F38');
    final amberBg  = PdfColor.fromHex('#FFFDE7');
    final grey     = PdfColor.fromHex('#757575');

    final schoolName    = school?.schoolName    ?? '';
    final schoolAddress = school?.schoolAddress ?? '';
    final schoolEmail   = school?.schoolEmailID ?? '';
    final schoolPhone   = school?.displayPhone  ?? '';

    final contactLine = [
      if (schoolPhone.isNotEmpty) 'Phone: $schoolPhone',
      if (schoolEmail.isNotEmpty) 'Email: $schoolEmail',
    ].join('   |   ');

    pw.Widget infoRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 92,
            child: pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: dark)),
          ),
          pw.Text(':  ',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: teal)),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );

    // ── logo widget for PDF ───────────────────────────────
    pw.Widget pdfLogo() {
      if (logoImage != null) {
        return pw.Container(
          width: 34,
          height: 34,
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            shape: pw.BoxShape.circle,
          ),
          child: pw.ClipOval(
            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
          ),
        );
      }
      // fallback: white circle with "S"
      return pw.Container(
        width: 34,
        height: 34,
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Center(
          child: pw.Text('S',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: teal)),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // ── header bar ────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: teal,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pdfLogo(),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: amber,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(copyLabel,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 6),

        // ── school info ───────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
              vertical: 10, horizontal: 14),
          color: tealBg,
          child: pw.Column(
            children: [
              if (schoolName.isNotEmpty)
                pw.Text(schoolName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: dark)),
              if (contactLine.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3),
                  child: pw.Text(contactLine,
                      textAlign: pw.TextAlign.center,
                      style:
                      pw.TextStyle(fontSize: 8, color: teal)),
                ),
              if (schoolAddress.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(schoolAddress,
                      textAlign: pw.TextAlign.center,
                      style:
                      pw.TextStyle(fontSize: 8, color: grey)),
                ),
            ],
          ),
        ),

        pw.SizedBox(height: 6),

        // ── PRODUCT RECEIPT banner ────────────────────────
        pw.Container(
          padding:
          const pw.EdgeInsets.symmetric(vertical: 7),
          color: teal,
          child: pw.Text(
            'PRODUCT RECEIPT',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),

        pw.SizedBox(height: 10),

        // ── 2-column info grid ────────────────────────────
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    infoRow('Receipt No',   controller.receiptNumber),
                    infoRow('Name',         controller.studentName),
                    infoRow('Parents Name', controller.fatherName),
                    infoRow('Class/Sec',    controller.classSection),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    infoRow('Payment Date',     controller.displayPayDate),
                    infoRow('Registration No.', controller.registrationNum),
                    infoRow('Academic Year',    controller.academicYear),
                    infoRow('Payment Mode',     controller.paymentMode),
                  ],
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 10),

        // ── product table ─────────────────────────────────
        pw.Table(
          border: pw.TableBorder.all(color: tealLine, width: 0.6),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: teal),
              children: [
                _pdfHead('Product'),
                _pdfHead('Quantity'),
                _pdfHead('Total Amount'),
              ],
            ),
            ...controller.printItems.asMap().entries.map((e) {
              final item = e.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: e.key.isEven ? tealBg : PdfColors.white),
                children: [
                  _pdfCell(item.product,       dark,  false),
                  _pdfCell('${item.quantity}', dark,  false),
                  _pdfCell('Rs ${item.amount}',teal,  true),
                ],
              );
            }),
            pw.TableRow(
              decoration: pw.BoxDecoration(color: amberBg),
              children: [
                _pdfCell('',                            dark,  false),
                _pdfCell('Total',                       dark,  true),
                _pdfCell('Rs ${controller.totalAmount}',dark,  true),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 24),

        // ── footer ────────────────────────────────────────
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                    height: 0.8, width: 140, color: teal),
                pw.SizedBox(height: 4),
                if (schoolName.isNotEmpty)
                  pw.Text('For $schoolName',
                      style: pw.TextStyle(
                          fontSize: 8,
                          color: teal,
                          fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 3),
                pw.Text('Authorized Signatory',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        color: dark)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _pdfHead(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(
        vertical: 7, horizontal: 10),
    child: pw.Text(text,
        style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 10)),
  );

  static pw.Widget _pdfCell(
      String text, PdfColor color, bool bold) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(
            vertical: 7, horizontal: 10),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight:
                bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color)),
      );
}

// ── reusable Flutter table widgets ───────────────────────────
class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.text,
    this.isBold = false,
    this.color,
  });

  final String text;
  final bool   isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}