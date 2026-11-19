import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import '../utils/app_snackbar.dart';

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

// Real card size: ATM / PAN / CR80 card = 85.6mm x 53.98mm (landscape).
// Card ko ek fixed "design size" me banaya hai (428 x 270 ~ 1.585 ratio) aur
// screen par FittedBox se scale hota hai -> kisi bhi phone par overflow nahi.
const double _kDesignW    = 428;
const double _kDesignH    = 270;
const double _kCardAspect = _kDesignW / _kDesignH;
const double _kCardRadius = 14;

// Captured card image + uska pixel size (print me same height nikalne ke liye)
class _CapturedCard {
  final Uint8List bytes;
  final int       width;
  final int       height;
  const _CapturedCard(this.bytes, this.width, this.height);
}

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
  // Shown on screen instead of raw API / exception text
  static const String _genericError = 'Something went wrong. Please try again.';

  bool   _isLoading = true;
  String? _error;
  IdCardStudentData? _student;

  // Keys used to capture the exact on-screen cards for printing / sharing
  final GlobalKey _frontKey = GlobalKey();
  final GlobalKey _backKey  = GlobalKey();

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
          // Server's own short message is shown only if it is clean
          AppSnackbar.error(model.messages ?? 'Failed to load data');
          setState(() => _error = _genericError);
        }
      } else {
        // Real status code prints only in console
        AppSnackbar.apiError(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
        setState(() => _error = _genericError);
      }
    } catch (e, s) {
      // Net off / timeout / bad response -> user sees "Something went wrong",
      // real error (with url) prints only in the console.
      AppSnackbar.apiError(e, stackTrace: s);
      setState(() => _error = _genericError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Screen ke card ka exact snapshot (photo adjust/zoom ke saath)
  Future<_CapturedCard?> _captureCard(GlobalKey key) async {
    final boundary =
    key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data  = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return null;
    return _CapturedCard(data.buffer.asUint8List(), image.width, image.height);
  }

  // Front + Back dono ek hi page par
  Future<Uint8List?> _buildCombinedPdf() async {
    final frontBytes = await _captureCard(_frontKey);
    final backBytes  = await _captureCard(_backKey);
    if (frontBytes == null || backBytes == null) {
      AppSnackbar.error(_genericError);
      return null;
    }

    final frontImg = pw.MemoryImage(frontBytes.bytes);
    final backImg  = pw.MemoryImage(backBytes.bytes);
    final t = _theme;

    // Front aur Back dono cards ki height bilkul same rakhne ke liye
    // ek common height nikalte hain (jo dono page me fit ho jaye)
    final pageFormat = PdfPageFormat.a4.landscape;
    const double pageMargin = 24;
    const double sideGap    = 20;
    final double sideW = (pageFormat.width - pageMargin * 2 - sideGap) / 2;
    final double maxH  = pageFormat.height - pageMargin * 2 - 40; // label ke liye jagah
    final double frontAsp = frontBytes.width / frontBytes.height;
    final double backAsp  = backBytes.width  / backBytes.height;
    double cardH = maxH;
    if (sideW / frontAsp < cardH) cardH = sideW / frontAsp;
    if (sideW / backAsp  < cardH) cardH = sideW / backAsp;
    final double frontW = cardH * frontAsp;
    final double backW  = cardH * backAsp;

    pw.Widget side(String label, pw.ImageProvider img, double w) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4, height: 14,
                decoration: pw.BoxDecoration(
                  color: t.pdfPrimary,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: t.pdfPrimary,
                      letterSpacing: 0.4)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.SizedBox(
              width: w,
              height: cardH,
              child: pw.Image(img, fit: pw.BoxFit.fill),
            ),
          ),
        ],
      ),
    );

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          side('Front Side', frontImg, frontW),
          pw.SizedBox(width: 20),
          side('Back Side', backImg, backW),
        ],
      ),
    ));
    return pdf.save();
  }

  String get _fileName =>
      'IDCard_${_student?.studentName ?? widget.studentId}';

  Future<void> _printCards() async {
    if (_student == null) return;
    try {
      final bytes = await _buildCombinedPdf();
      if (bytes == null) return;
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: _fileName,
      );
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    }
  }

  Future<void> _shareCards() async {
    if (_student == null) return;
    try {
      final bytes = await _buildCombinedPdf();
      if (bytes == null) return;
      await Printing.sharePdf(bytes: bytes, filename: '$_fileName.pdf');
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    }
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
        backgroundColor: const Color(0xFF97144D),
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
            tooltip: 'Print Front & Back',
            onPressed: _student != null ? _printCards : null,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share PDF',
            onPressed: _student != null ? _shareCards : null,
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

  // Card ke neeche ka shadow (capture ke bahar rakha hai taaki PDF me na aaye)
  Widget _shadowWrap(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIdCardView() {
    final s = _student!;

    final frontCard = _shadowWrap(
      RepaintBoundary(
        key: _frontKey,
        child: _FrontCard(
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
      ),
    );

    final backCard = _shadowWrap(
      RepaintBoundary(
        key: _backKey,
        child: _BackCard(
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
      ),
    );

    return Column(
      children: [
        _buildThemeSelector(),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _FlipCard(
                theme: _theme,
                front: frontCard,
                back:  backCard,
              ),
              // Refresh button: 7 colors wali row ke niche, right corner me
              Positioned(
                top: 8.h,
                right: 12.w,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _theme.primary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(Icons.refresh, color: Colors.white, size: 16.sp),
                  label: Text(
                    'Refresh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _fetchIdCard,
                ),
              ),
            ],
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
}

// ═══════════════════════════════════════════════════════════════════════
//  FLIP CARD  -  ungli se kisi bhi taraf 360° ghumao (X + Y dono axis)
//  1 ungli = ghumao, 2 ungli = zoom
//  "Reshape Card" button: Front -> Back -> Front  |  double tap = Front par wapas
// ═══════════════════════════════════════════════════════════════════════
class _FlipCard extends StatefulWidget {
  final Widget       front; // design size (428 x 270) ka widget
  final Widget       back;  // design size (428 x 270) ka widget
  final IdCardTheme  theme;

  const _FlipCard({
    required this.front,
    required this.back,
    required this.theme,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

// Rotation ko smooth animate karne ke liye chhota quaternion helper
class _Quat {
  final double w, x, y, z;
  const _Quat(this.w, this.x, this.y, this.z);
}

_Quat _quatFromMatrix(Matrix4 m) {
  final m00 = m.entry(0, 0), m01 = m.entry(0, 1), m02 = m.entry(0, 2);
  final m10 = m.entry(1, 0), m11 = m.entry(1, 1), m12 = m.entry(1, 2);
  final m20 = m.entry(2, 0), m21 = m.entry(2, 1), m22 = m.entry(2, 2);
  final tr = m00 + m11 + m22;
  double w, x, y, z;
  if (tr > 0) {
    final s = math.sqrt(tr + 1.0) * 2;
    w = 0.25 * s;
    x = (m21 - m12) / s;
    y = (m02 - m20) / s;
    z = (m10 - m01) / s;
  } else if (m00 > m11 && m00 > m22) {
    final s = math.sqrt(1.0 + m00 - m11 - m22) * 2;
    w = (m21 - m12) / s;
    x = 0.25 * s;
    y = (m01 + m10) / s;
    z = (m02 + m20) / s;
  } else if (m11 > m22) {
    final s = math.sqrt(1.0 + m11 - m00 - m22) * 2;
    w = (m02 - m20) / s;
    x = (m01 + m10) / s;
    y = 0.25 * s;
    z = (m12 + m21) / s;
  } else {
    final s = math.sqrt(1.0 + m22 - m00 - m11) * 2;
    w = (m10 - m01) / s;
    x = (m02 + m20) / s;
    y = (m12 + m21) / s;
    z = 0.25 * s;
  }
  final n = math.sqrt(w * w + x * x + y * y + z * z);
  return _Quat(w / n, x / n, y / n, z / n);
}

Matrix4 _matrixFromQuat(_Quat q) {
  final w = q.w, x = q.x, y = q.y, z = q.z;
  final m = Matrix4.identity();
  m.setEntry(0, 0, 1 - 2 * (y * y + z * z));
  m.setEntry(0, 1, 2 * (x * y - z * w));
  m.setEntry(0, 2, 2 * (x * z + y * w));
  m.setEntry(1, 0, 2 * (x * y + z * w));
  m.setEntry(1, 1, 1 - 2 * (x * x + z * z));
  m.setEntry(1, 2, 2 * (y * z - x * w));
  m.setEntry(2, 0, 2 * (x * z - y * w));
  m.setEntry(2, 1, 2 * (y * z + x * w));
  m.setEntry(2, 2, 1 - 2 * (x * x + y * y));
  return m;
}

_Quat _slerp(_Quat a, _Quat b, double t) {
  double bw = b.w, bx = b.x, by = b.y, bz = b.z;
  double dot = a.w * bw + a.x * bx + a.y * by + a.z * bz;
  if (dot < 0) {
    bw = -bw; bx = -bx; by = -by; bz = -bz;
    dot = -dot;
  }
  double k1, k2;
  if (dot > 0.9995) {
    k1 = 1 - t;
    k2 = t;
  } else {
    final theta = math.acos(dot);
    final sinT  = math.sin(theta);
    k1 = math.sin((1 - t) * theta) / sinT;
    k2 = math.sin(t * theta) / sinT;
  }
  final w = a.w * k1 + bw * k2;
  final x = a.x * k1 + bx * k2;
  final y = a.y * k1 + by * k2;
  final z = a.z * k1 + bz * k2;
  final n = math.sqrt(w * w + x * x + y * y + z * z);
  return _Quat(w / n, x / n, y / n, z / n);
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  // Pura rotation ek matrix me jama hota hai -> kisi bhi angle par
  // drag ki direction hamesha ungli ke hisaab se rehti hai.
  Matrix4 _rot = Matrix4.identity();

  // Zoom (2 ungliyon se pinch)
  double _zoom     = 1.0;
  double _baseZoom = 1.0;
  int    _lastPointers = 0;

  static const double _sensitivity = 0.012; // radians per pixel
  static const double _minZoom = 0.8;
  static const double _maxZoom = 3.0;

  // Reshape button / double tap ka smooth animation
  late final AnimationController _anim;
  _Quat?   _qFrom;
  _Quat?   _qTo;
  Matrix4? _target;
  double   _zFrom = 1.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )
      ..addListener(_onAnimTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _target != null) {
          setState(() {
            _rot  = _target!;
            _zoom = 1.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onAnimTick() {
    if (_qFrom == null || _qTo == null) return;
    final t = Curves.easeInOut.transform(_anim.value);
    setState(() {
      _rot  = _matrixFromQuat(_slerp(_qFrom!, _qTo!, t));
      _zoom = _zFrom + (1.0 - _zFrom) * t;
    });
  }

  void _animateTo(Matrix4 target) {
    _target = target;
    _qFrom  = _quatFromMatrix(_rot);
    _qTo    = _quatFromMatrix(target);
    _zFrom  = _zoom;
    _anim.forward(from: 0);
  }

  // Card abhi seedha Front side par (aur zoom 1x) hai ya nahi
  bool get _isFlatFront =>
      (_rot.entry(0, 0) + _rot.entry(1, 1) + _rot.entry(2, 2)) > 2.98 &&
          (_zoom - 1.0).abs() < 0.02;

  // Reshape Card button:
  //  - kisi bhi shape/zoom me ho -> Front par aa jata hai
  //  - Front par ho -> Back dikhata hai
  //  - Back par ho -> wapas Front
  void _toggleShape() {
    final target = _isFlatFront
        ? (Matrix4.identity()..rotateY(math.pi))
        : Matrix4.identity();
    _animateTo(target);
  }

  // Double tap = Front par wapas
  void _reset() => _animateTo(Matrix4.identity());

  void _onScaleStart(ScaleStartDetails d) {
    _anim.stop();
    _baseZoom     = _zoom;
    _lastPointers = d.pointerCount;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    // Ungliyon ki sankhya badli to ek frame skip (jhatka na lage)
    if (d.pointerCount != _lastPointers) {
      _lastPointers = d.pointerCount;
      _baseZoom     = _zoom;
      return;
    }
    if (d.pointerCount >= 2) {
      // 2 ungli = zoom
      setState(() {
        _zoom = (_baseZoom * d.scale).clamp(_minZoom, _maxZoom).toDouble();
      });
    } else {
      // 1 ungli = kisi bhi taraf ghumao
      final delta = Matrix4.identity()
        ..rotateX(d.focalPointDelta.dy * _sensitivity)
        ..rotateY(-d.focalPointDelta.dx * _sensitivity);
      setState(() => _rot = delta * _rot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    // Card ka seedha (Z) direction kis taraf hai -> Front dikh raha hai ya Back
    final bool frontVisible = _rot.entry(2, 2) >= 0;

    final Matrix4 persp  = Matrix4.identity()..setEntry(3, 2, 0.0008);
    final Matrix4 zoomM  = Matrix4.diagonal3Values(_zoom, _zoom, 1.0);
    final Matrix4 frontM = persp * zoomM * _rot;
    final Matrix4 backM  = frontM * (Matrix4.identity()..rotateY(math.pi));

    return LayoutBuilder(
      builder: (context, cons) {
        // Label + hint ke liye jagah chhodkar card ki size nikalte hain
        const double reserved = 190;
        double w = math.min(cons.maxWidth - 32, 440.0);
        final double availH = cons.maxHeight - reserved;
        if (availH > 0 && w / _kCardAspect > availH) {
          w = availH * _kCardAspect;
        }
        w = math.max(w, 160.0);
        final double h = w / _kCardAspect;

        Widget face(Key k, Matrix4 m, Widget child) => Transform(
          key: k,
          alignment: Alignment.center,
          transform: m,
          child: SizedBox(
            width: w,
            height: h,
            child: FittedBox(fit: BoxFit.contain, child: child),
          ),
        );

        final frontFace = face(const ValueKey('front-face'), frontM, widget.front);
        final backFace  = face(const ValueKey('back-face'),  backM,  widget.back);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onDoubleTap: _reset,
          child: SizedBox.expand(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        frontVisible ? 'Front Side' : 'Back Side',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: t.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: w,
                    height: h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      // Jo side saamne hai wo hamesha upar rahe
                      children: frontVisible
                          ? [backFace, frontFace]
                          : [frontFace, backFace],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'MOVE YOUR CARD IN ANY DIRECTION WITH YOUR FINGER TIPS\n'
                        'PINCH WITH TWO FINGERS TO ZOOM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                    ),
                    icon: const Icon(Icons.crop_rotate, color: Colors.white),
                    label: const Text(
                      'Reshape Card',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _toggleShape,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  PHOTO WIDGET (fixed - move / zoom nahi hota)
// ═══════════════════════════════════════════════════════════════════════
class _AdjustablePhoto extends StatelessWidget {
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

  // Photo fixed hai: koi move / zoom / touch gesture nahi.
  // Photo jaisi aati hai waisi hi dikhti hai.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 2),
        color: bgColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: imageUrl != null
            ? Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => placeholder,
        )
            : placeholder,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  FRONT CARD  (fixed design size 428 x 270, landscape)
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

    // Phone ki font-size setting card ka layout na bigaade
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(
        width: _kDesignW,
        height: _kDesignH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kCardRadius),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t.primary, t.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                          placeholder: (_, __) => Icon(Icons.school, color: t.primary, size: 24),
                          errorWidget: (_, __, ___) => Icon(Icons.school, color: t.primary, size: 24),
                        )
                            : Icon(Icons.school, color: t.primary, size: 24),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              (student.schoolName ?? 'School').toUpperCase(),
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (student.affiliated != null)
                            Text(
                              student.affiliated!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                            ),
                          Text(
                            student.schoolAddress ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_in_talk_rounded, color: Colors.white70, size: 10),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  student.schoolPhone ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ribbon
              Container(
                width: double.infinity,
                height: 18,
                alignment: Alignment.center,
                color: t.ribbonBg,
                child: Text(
                  'STUDENT IDENTITY CARD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: t.ribbonText,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // Body
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AdjustablePhoto(
                            imageUrl:      studentImgUrl,
                            width:         78,
                            height:        88,
                            borderRadius:  10,
                            borderColor:   t.primaryLight,
                            bgColor:       t.ribbonBg,
                            placeholder:   Icon(Icons.person, size: 36, color: t.primaryLight),
                            initialOffset: imgOffset,
                            initialScale:  imgScale,
                            onChanged:     onAdjust,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 78),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              student.className ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, cons) => FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: cons.maxWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.studentName ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Reg: ${student.registrationNo ?? '-'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 9.5,
                                        color: t.primaryLight,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        student.schoolEmail ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, IdCardTheme t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              '$label :',
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 10,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10,
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
//  BACK CARD  (fixed design size 428 x 270, landscape)
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

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(
        width: _kDesignW,
        height: _kDesignH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kCardRadius),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 26,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t.primary, t.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    (student.schoolName ?? 'School').toUpperCase(),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Father + Mother
                      SizedBox(
                        width: 112,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            const SizedBox(height: 6),
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
                      ),
                      Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: t.ribbonBg),

                      // Right: contact + transport + note
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, cons) => FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: cons.maxWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _backRow(Icons.phone_in_talk_rounded,    'Phone',     student.phone       ?? '-', t),
                                  _backRow(Icons.phone_android_outlined,   'WhatsApp',  student.whatsAppNo  ?? '-', t),
                                  _backRow(Icons.emergency_outlined,       'Emergency', student.emergencyNo ?? '-', t),
                                  _backRow(Icons.email_outlined,           'Email',     student.email       ?? '-', t),
                                  _backRow(Icons.home_outlined,            'Address',   student.address     ?? '-', t),

                                  if ((student.transportUser ?? '').toLowerCase() == 'yes') ...[
                                    Divider(color: t.ribbonBg, thickness: 1, height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_bus_outlined, size: 11, color: t.primaryLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Transport Details',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: t.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    _backRow(Icons.route_outlined, 'Route No', student.routeNo     ?? '-', t),
                                    _backRow(Icons.place_outlined, 'Stop',     student.pickupPoint ?? '-', t),
                                  ],

                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: t.ribbonBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'If found, please return to the school.\n'
                                          '${student.schoolName ?? ''} | ${student.schoolAddress ?? ''}\n'
                                          '📞 ${student.schoolPhone ?? ''}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 8,
                                          color: _textSecondary,
                                          height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                height: 20,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                color: t.footerBg,
                child: const Text(
                  'Authorised Signature ____________________',
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ),
            ],
          ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        _AdjustablePhoto(
          imageUrl:      imgUrl,
          width:         46,
          height:        52,
          borderRadius:  8,
          borderColor:   t.primaryLight,
          bgColor:       t.ribbonBg,
          placeholder:   Icon(fallback, size: 24, color: t.primaryLight),
          initialOffset: offset,
          initialScale:  scale,
          onChanged:     onChanged,
        ),
        const SizedBox(height: 3),
        // Text(label,
        //     style: TextStyle(
        //         fontSize: 9.sp,
        //         color: t.primaryLight,
        //         fontWeight: FontWeight.w600)),
        // SizedBox(height: 2.h),
        SizedBox(
          width: 108,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _backRow(IconData icon, String label, String value, IdCardTheme t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 11, color: t.primaryLight),
          const SizedBox(width: 4),
          SizedBox(
            width: 54,
            child: Text(
              '$label :',
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 9.5,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 9.5,
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