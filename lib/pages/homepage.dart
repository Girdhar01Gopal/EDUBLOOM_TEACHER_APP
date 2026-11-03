import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/home_page_controller.dart';
import '../infrastructures/routes/page_constants.dart';
import '../res/app_url.dart';
import '../wigets/app_drawer.dart';

class _DS {
  static const coral     = Color(0xFFFF6B6B);
  static const sky       = Color(0xFF4CC9F0);
  static const sunshine  = Color(0xFFFFD166);
  static const mint      = Color(0xFF06D6A0);
  static const plum      = Color(0xFF8338EC);
  static const navy      = Color(0xFF1A2847);
  static const navyMid   = Color(0xFF243461);
  static const bg        = Color(0xFFF7F3EE);
  static const textDark  = Color(0xFF1A2847);
  static const textMid   = Color(0xFF5A6A8A);
  static const textLight = Color(0xFF9BACC8);
  static const tealDeep   = Color(0xFF5E0E29);
  static const tealDark   = Color(0xFF7A1236);
  static const tealMid    = Color(0xFF8F1542);
  static const tealAccent = Color(0xFFA11A4D);
  static const tealLight  = Color(0xFFC75080);
  static const tealPale   = Color(0xFFE8B8CC);
  static const appBarGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E0E29), Color(0xFF7A1236), Color(0xFF8F1542)],
  );
}

class _ZoomableLogo extends StatefulWidget {
  final String logoUrl;
  const _ZoomableLogo({required this.logoUrl});

  @override
  State<_ZoomableLogo> createState() => _ZoomableLogoState();
}

class _ZoomableLogoState extends State<_ZoomableLogo> {
  final TransformationController _ctrl = TransformationController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: InteractiveViewer(
        transformationController: _ctrl,
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          widget.logoUrl,
          height: 50.h,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            height: 50.h,
            width: 50.h,
            decoration: BoxDecoration(
              color: _DS.coral,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class Dhashoard extends GetView<DashboardScreenController> {
  const Dhashoard({super.key});

  // Built once, reused on every rebuild.
  static const _watermark = RepaintBoundary(
    child: IgnorePointer(
      child: CustomPaint(painter: _PlayschoolWatermarkPainter()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DS.bg,
      drawer: AppDrawer(),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          const Positioned.fill(child: _watermark),
          _DashboardBody(controller: controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 88.h,
      centerTitle: true,
      titleSpacing: 0,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: _DS.appBarGrad),
        child: Stack(
          children: [
            Positioned(
              left: -30, top: -20,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.tealLight.withOpacity(0.20),
                ),
              ),
            ),
            Positioned(
              right: -20, bottom: -30,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.tealAccent.withOpacity(0.25),
                ),
              ),
            ),
            Positioned(
              right: 100, top: -15,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.tealPale.withOpacity(0.18),
                ),
              ),
            ),
          ],
        ),
      ),
      title: Obx(
            () => SizedBox(
          width: MediaQuery.of(context).size.width * 0.46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ZoomableLogo(
                logoUrl: '${AppUrl.dashurl}/${controller.schoollogo.value}',
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      actions: [
        _BounceTap(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
            width: 38.w, height: 38.w,
            decoration: BoxDecoration(
              color: _DS.tealAccent.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _DS.tealLight.withOpacity(0.35), width: 1),
            ),
            child: Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18.sp),
          ),
          onTap: () => Get.toNamed(RouteName.changepassword),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Watermark – icon layout is generated ONCE and shared (no per-build random).
// ═══════════════════════════════════════════════════════════════════════════
class _PlayschoolWatermarkPainter extends CustomPainter {
  const _PlayschoolWatermarkPainter();

  static const _types = ['star','heart','abc','pencil','balloon','book','sun','cloud','music','apple','butterfly','crown'];

  static final List<_WatermarkIcon> _icons = _buildIcons();

  static List<_WatermarkIcon> _buildIcons() {
    final rng = math.Random(42);
    return List.generate(48, (i) => _WatermarkIcon(
      type: _types[i % _types.length],
      x: rng.nextDouble(), y: rng.nextDouble(),
      size: 26 + rng.nextDouble() * 32,
      angle: (rng.nextDouble() - 0.5) * 0.9,
      opacity: 0.08 + rng.nextDouble() * 0.09,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final ic in _icons) {
      paint.color = _iconColor(ic.type).withOpacity(ic.opacity);
      canvas.save();
      canvas.translate(ic.x * size.width, ic.y * size.height);
      canvas.rotate(ic.angle);
      _drawIcon(canvas, paint, ic.type, ic.size);
      canvas.restore();
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'star': return _DS.sunshine;
      case 'heart': return _DS.coral;
      case 'abc': return _DS.plum;
      case 'pencil': return _DS.mint;
      case 'balloon': return _DS.sky;
      case 'book': return _DS.coral;
      case 'sun': return _DS.sunshine;
      case 'cloud': return _DS.sky;
      case 'music': return _DS.plum;
      case 'apple': return _DS.coral;
      case 'butterfly': return _DS.mint;
      case 'crown': return _DS.sunshine;
      default: return _DS.coral;
    }
  }

  void _drawIcon(Canvas canvas, Paint paint, String type, double s) {
    final h = s / 2;
    switch (type) {
      case 'star': _drawStar(canvas, paint, h); break;
      case 'heart': _drawHeart(canvas, paint, h); break;
      case 'balloon': _drawBalloon(canvas, paint, h); break;
      case 'sun': _drawSun(canvas, paint, h); break;
      case 'cloud': _drawCloud(canvas, paint, h); break;
      case 'crown': _drawCrown(canvas, paint, h); break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: s * 0.9, height: s * 0.9),
            Radius.circular(s * 0.2),
          ),
          paint,
        );
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = outerAngle + 36 * math.pi / 180;
      if (i == 0) {
        path.moveTo(r * math.cos(outerAngle), r * math.sin(outerAngle));
      } else {
        path.lineTo(r * math.cos(outerAngle), r * math.sin(outerAngle));
      }
      path.lineTo(r * 0.45 * math.cos(innerAngle), r * 0.45 * math.sin(innerAngle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint, double r) {
    final path = Path()
      ..moveTo(0, r * 0.4)
      ..cubicTo(-r * 1.0, -r * 0.1, -r * 1.0, -r * 0.9, 0, -r * 0.3)
      ..cubicTo(r * 1.0, -r * 0.9, r * 1.0, -r * 0.1, 0, r * 0.4)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawBalloon(Canvas canvas, Paint paint, double r) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -r * 0.3), width: r * 1.4, height: r * 1.7),
      paint,
    );
    final sPaint = Paint()..color = paint.color..strokeWidth = r * 0.1..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, r * 0.6), Offset(r * 0.2, r * 1.1), sPaint);
  }

  void _drawSun(Canvas canvas, Paint paint, double r) {
    canvas.drawCircle(Offset.zero, r * 0.55, paint);
    final sPaint = Paint()
      ..color = paint.color
      ..strokeWidth = r * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final a = i * 45 * math.pi / 180;
      canvas.drawLine(
        Offset(r * 0.70 * math.cos(a), r * 0.70 * math.sin(a)),
        Offset(r * 1.00 * math.cos(a), r * 1.00 * math.sin(a)),
        sPaint,
      );
    }
  }

  void _drawCloud(Canvas canvas, Paint paint, double r) {
    canvas.drawCircle(Offset(-r * 0.4, 0), r * 0.4, paint);
    canvas.drawCircle(Offset(r * 0.4, 0), r * 0.4, paint);
    canvas.drawCircle(Offset(0, -r * 0.3), r * 0.5, paint);
    canvas.drawRect(Rect.fromLTRB(-r * 0.8, 0, r * 0.8, r * 0.5), paint);
  }

  void _drawCrown(Canvas canvas, Paint paint, double r) {
    final path = Path()
      ..moveTo(-r, r * 0.5)
      ..lineTo(-r, -r * 0.2)
      ..lineTo(-r * 0.4, r * 0.2)
      ..lineTo(0, -r * 0.7)
      ..lineTo(r * 0.4, r * 0.2)
      ..lineTo(r, -r * 0.2)
      ..lineTo(r, r * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PlayschoolWatermarkPainter old) => false;
}

class _WatermarkIcon {
  final String type;
  final double x, y, size, angle, opacity;
  const _WatermarkIcon({required this.type, required this.x, required this.y, required this.size, required this.angle, required this.opacity});
}

class _DashboardBody extends StatefulWidget {
  final DashboardScreenController controller;
  const _DashboardBody({required this.controller});

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final Animation<double> _op0, _op2, _op3;
  late final Animation<Offset> _sl0, _sl2, _sl3;

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _op0 = _fade(0.00, 0.30); _sl0 = _slide(0.00, 0.30, const Offset(0, -0.20));
    _op2 = _fade(0.36, 0.66); _sl2 = _slide(0.36, 0.66, const Offset(0, 0.25));
    _op3 = _fade(0.54, 1.00); _sl3 = _slide(0.54, 1.00, const Offset(0, 0.25));
    _stagger.forward();
  }

  Animation<double> _fade(double b, double e) => Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _stagger, curve: Interval(b, e, curve: Curves.easeOut)));

  Animation<Offset> _slide(double b, double e, Offset from) =>
      Tween<Offset>(begin: from, end: Offset.zero).animate(
          CurvedAnimation(parent: _stagger, curve: Interval(b, e, curve: Curves.easeOutCubic)));

  Widget _wrap(Animation<double> op, Animation<Offset> sl, Widget child) =>
      FadeTransition(opacity: op, child: SlideTransition(position: sl, child: child));

  @override
  void dispose() { _stagger.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return RefreshIndicator(
      color: _DS.tealDark,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await c.fetchBirthday();
        await c.totalamount();
        await c.totaldue();
        c.onInit();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wrap(_op0, _sl0, _WelcomeBanner(controller: c)),
            // 10 + 18 + 18 = same gap the old (empty) stats row left here.
            SizedBox(height: 46.h),
            _wrap(_op2, _sl2, _BirthdayCard(controller: c)),
            SizedBox(height: 20.h),
            FadeTransition(opacity: _op3, child: const _SectionHeader(title: "Quick Actions", emoji: "⚡")),
            SizedBox(height: 12.h),
            _wrap(_op3, _sl3, _DashboardGrid(controller: c)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_DS.navy, _DS.navyMid]),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.4)),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_DS.navy.withOpacity(0.2), Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatefulWidget {
  final DashboardScreenController controller;
  const _WelcomeBanner({required this.controller});

  @override
  State<_WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<_WelcomeBanner> with TickerProviderStateMixin {
  late final AnimationController _orb;
  late final AnimationController _float;
  late final Animation<double> _shimmerPos;

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _shimmerPos = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _orb.dispose(); _float.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_orb, _float]),
        builder: (_, child) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF5E0E29), Color(0xFF7A1236), Color(0xFF8F1542)],
              ),
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [BoxShadow(color: const Color(0xFF5E0E29).withOpacity(0.38), blurRadius: 32, offset: const Offset(0, 12))],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(right: -10 + _orb.value * 16, top: -20 + _orb.value * 10, child: _colorOrb(120, _DS.tealLight, 0.22)),
                Positioned(right: 55 - _orb.value * 8, bottom: -30 + _orb.value * 6, child: _colorOrb(80, _DS.tealAccent, 0.28)),
                Positioned(left: 60 + _orb.value * 6, bottom: -15, child: _colorOrb(55, _DS.tealPale, 0.20)),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: CustomPaint(painter: _ShimmerPainter(_shimmerPos.value)),
                  ),
                ),
                child!,
              ],
            ),
          );
        },
        child: Row(
          children: [
            const _PulsingRingAvatar(),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Obx(() => Text(
                        "Welcome, ${widget.controller.schoolname.value}",
                        style: TextStyle(fontSize: 17.sp, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      )),
                      SizedBox(width: 4.w),
                      Text("👋", style: TextStyle(fontSize: 17.sp)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _DS.tealAccent.withOpacity(0.30),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: _DS.tealLight.withOpacity(0.40), width: 1),
                    ),
                    child: Text("📅  $today", style: TextStyle(fontSize: 10.5.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorOrb(double size, Color color, double opacity) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)));
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  const _ShimmerPainter(this.progress);

  static final _colors = [
    Colors.white.withOpacity(0.0),
    Colors.white.withOpacity(0.08),
    Colors.white.withOpacity(0.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: _colors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(progress * size.width - size.width * 0.4, 0, size.width * 0.8, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

class _PulsingRingAvatar extends StatefulWidget {
  const _PulsingRingAvatar();

  @override
  State<_PulsingRingAvatar> createState() => _PulsingRingAvatarState();
}

class _PulsingRingAvatarState extends State<_PulsingRingAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ring;

  static const _avatar = CircleAvatar(
    backgroundColor: _DS.tealDeep,
    child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
  );

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _ring = Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ring,
      builder: (_, child) => Container(
        width: 64.w, height: 64.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [
            _DS.tealLight.withOpacity(_ring.value),
            _DS.tealPale.withOpacity(_ring.value),
            _DS.tealAccent.withOpacity(_ring.value),
            _DS.tealMid.withOpacity(_ring.value),
            _DS.tealLight.withOpacity(_ring.value),
          ]),
        ),
        padding: const EdgeInsets.all(2.5),
        child: child,
      ),
      child: _avatar,
    );
  }
}

class _BirthdayCard extends StatelessWidget {
  final DashboardScreenController controller;
  const _BirthdayCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final birthdays = controller.birthdaylist;
      if (birthdays.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFF5A623)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(22.r), topRight: Radius.circular(22.r)),
              boxShadow: [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.30), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 30.w, height: 30.w,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(14.r)),
                  child: const Icon(Icons.cake_rounded, color: Colors.white, size: 22),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Birthdays 🎉", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text("${birthdays.length} student(s) celebrating today", style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 145.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF2),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22.r), bottomRight: Radius.circular(22.r)),
              border: Border.all(color: const Color(0xFFF5A623).withOpacity(0.18), width: 1.2),
              boxShadow: [BoxShadow(color: const Color(0xFFF5A623).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                final s = birthdays[index];
                final name = s.studentName ?? "?";
                final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
                final wishMsg =
                    "🎂 Wish you a Very Happy Birthday, ${name.trim()}! 🎉🥳\n"
                    "From: ${controller.schoollname.value}";

                return _SlideIn(
                  delay: Duration(milliseconds: 60 + index * 110),
                  from: const Offset(0.35, 0),
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _BirthdayItem(
                      initial: initial,
                      student: s,
                      onWish: () => controller.sendWishOnWhatsApp(
                        s.phone ?? "",
                        s.studentName ?? "",
                        wishMsg,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _BirthdayItem extends StatefulWidget {
  final String initial;
  final dynamic student;
  final VoidCallback onWish;

  const _BirthdayItem({required this.initial, required this.student, required this.onWish});

  @override
  State<_BirthdayItem> createState() => _BirthdayItemState();
}

class _BirthdayItemState extends State<_BirthdayItem> {
  bool _pressed = false;

  String formatDate(String date) {
    try {
      if (date.isEmpty) return "";
      return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
    } catch (_) { return date; }
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: 230.w,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFFFF3DC) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(_pressed ? 0.08 : 0.04), blurRadius: _pressed ? 16 : 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w, height: 40.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFF5A623), Color(0xFFE08A00)],
                    ),
                  ),
                  child: Center(child: Text(widget.initial, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16.sp))),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    widget.student.studentName ?? "Unknown",
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _DS.textDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              "🎂 DOB: ${formatDate(widget.student.dateOfBirth ?? "")}",
              style: TextStyle(fontSize: 10.sp, color: _DS.textMid, fontWeight: FontWeight.w500),
            ),
            Text(
              "👨 ${widget.student.fatherName ?? ""}  •  👩 ${widget.student.motherName ?? ""}",
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.sp, color: _DS.textLight),
            ),
            SizedBox(height: 6.h),
            _BounceTap(
              onTap: widget.onWish,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("🎁 ", style: TextStyle(fontSize: 12.sp)),
                    Text("Wish on WhatsApp", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🟦  DASHBOARD GRID
// ═══════════════════════════════════════════════════════════════════════════
class _DashboardGrid extends StatelessWidget {
  final DashboardScreenController controller;
  const _DashboardGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredList;
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.05,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final c = item.color;
          return _SlideIn(
            delay: Duration(milliseconds: 40 * index),
            from: const Offset(0, 0.30),
            child: _GridCard(
              item: item,
              gradientColors: [c, Color.lerp(c, Colors.white, 0.28)!],
              onTap: () => controller.onSelectedBottom(index),
            ),
          );
        },
      );
    });
  }
}

class _GridCard extends StatefulWidget {
  final dynamic item;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  const _GridCard({required this.item, required this.gradientColors, required this.onTap});

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _WaveTopClipper extends CustomClipper<Path> {
  const _WaveTopClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.72, size.width * 0.50, size.height * 0.63)
      ..quadraticBezierTo(size.width * 0.80, size.height * 0.54, size.width, size.height * 0.65)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_WaveTopClipper old) => false;
}

class _GridCardState extends State<_GridCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _ripple;

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  }

  @override
  void dispose() { _ripple.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c1 = widget.gradientColors[0];
    final c2 = widget.gradientColors[1];
    final emoji = widget.item.emoji;

    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true); _ripple.forward(from: 0); },
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.89 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: c1.withOpacity(_pressed ? 0.45 : 0.22), blurRadius: _pressed ? 22 : 12, offset: Offset(0, _pressed ? 8 : 4)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: const _WaveTopClipper(),
                  child: AnimatedBuilder(
                    animation: _ripple,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(c1, Colors.white, _ripple.value * 0.15)!,
                            Color.lerp(c2, Colors.white, _ripple.value * 0.15)!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(right: -6, top: -6, child: Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)))),
              Positioned(left: 4, top: 4, child: Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.14)))),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 46.w, height: 46.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: c1.withOpacity(0.38), blurRadius: 14, offset: const Offset(0, 5))],
                          ),
                          child: Center(
                            child: emoji != null && emoji.isNotEmpty
                                ? Text(emoji, style: TextStyle(fontSize: 24.sp))
                                : Icon(widget.item.image, size: 22.sp, color: c1),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Transform.translate(
                          offset: const Offset(0, 4),
                          child: Text(
                            widget.item.name,
                            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: _DS.textDark, height: 1.25, letterSpacing: 0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset from;
  const _SlideIn({required this.child, required this.delay, required this.from});

  @override
  State<_SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<_SlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _op;
  late final Animation<Offset> _sl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _op = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _sl = Tween<Offset>(begin: widget.from, end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _op, child: SlideTransition(position: _sl, child: widget.child));
  }
}

class _BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _BounceTap({required this.child, this.onTap});

  @override
  State<_BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<_BounceTap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.84), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.84, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
    ]).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { _ctrl.forward(from: 0); widget.onTap?.call(); },
      behavior: HitTestBehavior.translucent,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}