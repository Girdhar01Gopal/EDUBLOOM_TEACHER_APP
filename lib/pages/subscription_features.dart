import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as https;
import 'package:teacher_app_edubloom/pages/school_expiry_fee_payment_screen.dart';
import '../controller/home_page_controller.dart';
import '../models/plansubscriptionmodel.dart';
import '../models/school_expiry_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// HELPER: SubSlideIn
// ════════════════════════════════════════════════════════════════════════════

class _SubSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset from;
  const _SubSlideIn({required this.child, required this.delay, required this.from});

  @override
  State<_SubSlideIn> createState() => _SubSlideInState();
}

class _SubSlideInState extends State<_SubSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _op;
  late Animation<Offset> _sl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _op = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _sl = Tween<Offset>(begin: widget.from, end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _op, child: SlideTransition(position: _sl, child: widget.child));
}

// ════════════════════════════════════════════════════════════════════════════
// 1.  SUBSCRIPTION MINI CARD  — fully API-driven via ExpiryData
//     Top row always visible. Detail rows expand/collapse on tap.
// ════════════════════════════════════════════════════════════════════════════

class SubscriptionMiniCard extends StatefulWidget {
  final String expiryDateStr;
  const SubscriptionMiniCard({super.key, this.expiryDateStr = ''});

  @override
  State<SubscriptionMiniCard> createState() => _SubscriptionMiniCardState();
}

class _SubscriptionMiniCardState extends State<SubscriptionMiniCard>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseVal;

  // ── expand / collapse ─────────────────────────────────────────────────────
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  late Animation<double> _chevronAnim;
  bool _isExpanded = false;

  // ✅ ADD THIS getter
  // String get _planName => _ed?.planName ?? 'Know your Plans';
  String get _planName => _ed?.planName ?? '';

  // ── helpers computed from ExpiryData ──────────────────────────────────────
  DashboardScreenController get _ctrl => Get.find<DashboardScreenController>();

  ExpiryData? get _ed => _ctrl.expiryInfo.value;

  DateTime get _expiryDate {
    if (_ed != null) return _ed!.expirydate;
    try {
      if (widget.expiryDateStr.isNotEmpty) return DateTime.parse(widget.expiryDateStr);
    } catch (_) {}
    return DateTime(2026, 6, 12);
  }

  DateTime get _startDate =>
      _ed?.createDate ?? _expiryDate.subtract(const Duration(days: 42));

  int get _daysRemaining {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final exp   = DateTime(_expiryDate.year, _expiryDate.month, _expiryDate.day);
    return exp.difference(today).inDays;
  }

  double get _usagePercent {
    final today   = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start   = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final exp     = DateTime(_expiryDate.year, _expiryDate.month, _expiryDate.day);
    final total   = exp.difference(start).inDays;
    final elapsed = today.difference(start).inDays;
    if (total <= 0) return 1.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  bool get _isCritical => _daysRemaining <= 15;

  // ── lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseVal = Tween<double>(begin: 0.85, end: 1.0).animate(_pulse);

    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic);
    _chevronAnim = Tween<double>(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandCtrl.forward();
      } else {
        _expandCtrl.reverse();
      }
    });
  }

  // ── open dialog (only on chevron tap) ────────────────────────────────────
  void _openSubscriptionDialog() {
    final ed = _ed;
    if (ed != null) {
      _showDialogWithData(ed);
    } else {
      _showDialogWithFallback();
    }
  }

  void _showDialogWithData(ExpiryData ed) {
    final fmt        = DateFormat('dd MMM yyyy');
    final today      = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final expiryOnly = DateTime(ed.expirydate.year, ed.expirydate.month, ed.expirydate.day);
    final daysRemaining   = expiryOnly.difference(today).inDays;
    final startDate       = ed.createDate;
    final startOnly       = DateTime(startDate.year, startDate.month, startDate.day);
    final totalDays       = expiryOnly.difference(startOnly).inDays;
    final elapsed         = today.difference(startOnly).inDays;
    final usagePercent    = totalDays > 0 ? (elapsed / totalDays).clamp(0.0, 1.0) : 1.0;
    final isCritical      = daysRemaining <= 15;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'subscription',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, 16))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                      ),
                      child: Column(
                        children: [
                          Text('Subscription Plan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 4.h),
                          Text('Your current active package details',
                              style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                        ],
                      ),
                    ),

                    // ── Body ──────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
                      child: Column(
                        children: [
                          Text(
                            '$daysRemaining',
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: FontWeight.w900,
                              color: isCritical ? Colors.red : const Color(0xFF6C63FF),
                              height: 1,
                            ),
                          ),
                          Text('Days Remaining',
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                          SizedBox(height: 18.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Usage Progress',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                              Text('${(usagePercent * 100).toInt()}%',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade700)),
                            ],
                          ),
                          SizedBox(height: 7.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: LinearProgressIndicator(
                              value: usagePercent,
                              minHeight: 8.h,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation(Colors.green),
                            ),
                          ),

                          SizedBox(height: 20.h),
                          const Divider(height: 1),
                          SizedBox(height: 16.h),

                          _InfoRow(label: 'Plan Name', value: ed.planName ?? 'N/A', valueBold: true),
                          _InfoRow(label: 'School ID', value: ed.schoolId, valueBold: true),
                          _InfoRow(
                              label: 'Created On',
                              value: fmt.format(ed.createDate),
                              valueBold: true),
                          _InfoRow(
                            label: 'Expiry Date',
                            value: fmt.format(ed.expirydate),
                            valueColor: isCritical ? Colors.red : null,
                            valueBold: true,
                          ),
                          _InfoRow(
                            label: 'Status',
                            value: isCritical ? 'Expiring Soon' : 'Active',
                            valueColor: isCritical ? Colors.orange : Colors.green,
                            valueBold: true,
                          ),

                          SizedBox(height: 16.h),

                          if (isCritical)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: const Color(0xFFF59E0B).withOpacity(0.40)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Color(0xFFB45309), size: 18),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Renew your subscription before expiry\nto avoid service interruption.',
                                      style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: const Color(0xFF92400E),
                                          height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 20.h),

                          // SizedBox(
                          //   width: double.infinity,
                          //   height: 50.h,
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       Navigator.of(ctx).pop();
                          //       Get.to(
                          //             () => const SubscriptionPlansScreen(),
                          //         transition: Transition.rightToLeft,
                          //         duration: const Duration(milliseconds: 350),
                          //       );
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: const Color(0xFF6C63FF),
                          //       foregroundColor: Colors.white,
                          //       elevation: 0,
                          //       shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(14.r)),
                          //     ),
                          //     child: Text('Subscribe now',
                          //         style: TextStyle(
                          //             fontSize: 15.sp, fontWeight: FontWeight.w700)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialogWithFallback() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'subscription',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim,
            child: _SubscriptionDialog(
              daysRemaining: _daysRemaining,
              usagePercent:  _usagePercent,
              planName:      _planName,
              startDate:     _startDate,
              expiryDate:    _expiryDate,
            ),
          ),
        );
      },
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ed       = _ctrl.expiryInfo.value;
      final fmt      = DateFormat('dd MMM yyyy');
      final days     = _daysRemaining;
      final usage    = _usagePercent;
      final critical = _isCritical;

      return AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: critical
                  ? Colors.red.withOpacity(0.35)
                  : const Color(0xFF6C63FF).withOpacity(0.22),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: (critical ? Colors.red : const Color(0xFF6C63FF))
                    .withOpacity(0.13 + _pulseVal.value * 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── ALWAYS VISIBLE: top row (tap to expand/collapse) ──────────
            GestureDetector(
              onTap: ed != null ? _toggleExpand : null,
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
                child: Row(
                  children: [
                    _DaysCircle(days: days, isCritical: critical),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _planName,
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A2847)),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Expires ${fmt.format(_expiryDate)}',
                            style: TextStyle(
                                fontSize: 10.5.sp,
                                color: critical
                                    ? Colors.red.shade400
                                    : Colors.grey.shade500,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 7.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: LinearProgressIndicator(
                              value: usage,
                              minHeight: 5.h,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                  critical ? Colors.red : Colors.green),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '${(usage * 100).toInt()}% usage',
                            style: TextStyle(
                                fontSize: 9.sp, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                    // Chevron: rotates on expand, opens dialog on long press
                    GestureDetector(
                      onTap: ed != null ? _toggleExpand : _openSubscriptionDialog,
                      onLongPress: _openSubscriptionDialog,
                      child: AnimatedBuilder(
                        animation: _chevronAnim,
                        builder: (_, __) => Transform.rotate(
                          angle: _chevronAnim.value * math.pi * 2,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.10),
                                shape: BoxShape.circle),
                            child: Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF6C63FF),
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── EXPANDABLE: detail rows ───────────────────────────────────
            if (ed != null)
              SizeTransition(
                sizeFactor: _expandAnim,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: _expandAnim,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 18.w, right: 18.w, bottom: 14.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(height: 1, color: Colors.grey.shade200),
                        SizedBox(height: 10.h),
                        _MiniInfoRow(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Plan Name',
                          value: ed.planName ?? 'N/A',
                          iconColor: const Color(0xFF6C63FF),
                        ),
                        SizedBox(height: 6.h),
                        _MiniInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'School ID',
                          value: ed.schoolId,
                          iconColor: const Color(0xFF6C63FF),
                        ),
                        SizedBox(height: 6.h),
                        _MiniInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Created On',
                          value: fmt.format(ed.createDate),
                          iconColor: Colors.teal,
                        ),
                        SizedBox(height: 6.h),
                        _MiniInfoRow(
                          icon: Icons.event_outlined,
                          label: 'Expiry Date',
                          value: fmt.format(ed.expirydate),
                          iconColor: critical ? Colors.red : const Color(0xFF6C63FF),
                          valueColor: critical ? Colors.red : null,
                        ),
                        SizedBox(height: 6.h),
                        _MiniInfoRow(
                          icon: critical
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded,
                          label: 'Status',
                          value: critical ? 'Expiring Soon' : 'Active',
                          iconColor: critical ? Colors.orange : Colors.green,
                          valueColor: critical ? Colors.orange : Colors.green,
                        ),
                        SizedBox(height: 10.h),
                        // View full details button
                        GestureDetector(
                          onTap: _openSubscriptionDialog,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.07),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: const Color(0xFF6C63FF).withOpacity(0.18)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.open_in_new_rounded,
                                    color: const Color(0xFF6C63FF), size: 13.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'View Full Details',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
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
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MINI INFO ROW  — used inside the card body
// ════════════════════════════════════════════════════════════════════════════

class _MiniInfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    iconColor;
  final Color?   valueColor;

  const _MiniInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: iconColor),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade500),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1A2847),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DAYS CIRCLE
// ════════════════════════════════════════════════════════════════════════════

class _DaysCircle extends StatelessWidget {
  final int days;
  final bool isCritical;
  const _DaysCircle({required this.days, required this.isCritical});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54.w, height: 54.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (days / 42).clamp(0.0, 1.0),
            strokeWidth: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
                isCritical ? Colors.red : const Color(0xFF6C63FF)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$days',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isCritical ? Colors.red : const Color(0xFF6C63FF),
                      height: 1)),
              Text('days',
                  style: TextStyle(fontSize: 7.sp, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION DIALOG (fallback)
// ════════════════════════════════════════════════════════════════════════════

class _SubscriptionDialog extends StatefulWidget {
  final int daysRemaining;
  final double usagePercent;
  final String planName;
  final DateTime startDate;
  final DateTime expiryDate;

  const _SubscriptionDialog({
    required this.daysRemaining,
    required this.usagePercent,
    required this.planName,
    required this.startDate,
    required this.expiryDate,
  });

  @override
  State<_SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<_SubscriptionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _progressAnim = Tween<double>(begin: 0, end: widget.usagePercent)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));
    _progressCtrl.forward();
  }

  @override
  void dispose() { _progressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final bool isCritical = widget.daysRemaining <= 15;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, 16))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                children: [
                  Text('Subscription Plan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4.h),
                  Text('Your current active package details',
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
              child: Column(
                children: [
                  Text('${widget.daysRemaining}',
                      style: TextStyle(
                          fontSize: 52.sp,
                          fontWeight: FontWeight.w900,
                          color: isCritical ? Colors.red : const Color(0xFF6C63FF),
                          height: 1)),
                  Text('Days Remaining',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Usage Progress',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                      AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (_, __) => Text('${(_progressAnim.value * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700)),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h),
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: _progressAnim.value,
                        minHeight: 8.h,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const Divider(height: 1),
                  SizedBox(height: 16.h),
                  _InfoRow(label: 'Plan Name', value: widget.planName, valueBold: true),
                  _InfoRow(label: 'Start Date', value: fmt.format(widget.startDate), valueBold: true),
                  _InfoRow(label: 'Expiry Date', value: fmt.format(widget.expiryDate), valueBold: true),
                  _InfoRow(label: 'Status', value: 'Active', valueColor: Colors.green, valueBold: true),
                  SizedBox(height: 16.h),
                  if (isCritical)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.40)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFB45309), size: 18),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Renew your subscription before expiry\nto avoid service interruption.',
                              style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFF92400E),
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20.h),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50.h,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //       Get.to(
                  //             () => const SubscriptionPlansScreen(),
                  //         transition: Transition.rightToLeft,
                  //         duration: const Duration(milliseconds: 350),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF6C63FF),
                  //       foregroundColor: Colors.white,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(14.r)),
                  //     ),
                  //     child: Text('Renew Subscription',
                  //         style: TextStyle(
                  //             fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// INFO ROW
// ════════════════════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _InfoRow(
      {required this.label,
        required this.value,
        this.valueColor,
        this.valueBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12.5.sp, color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF1A2847),
              )),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION PLANS SCREEN — API-driven
// ════════════════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════════════════
// COLOR CONSTANTS  — paste these at the top of your file (or in a constants file)
// ════════════════════════════════════════════════════════════════════════════

const Color _kBg           = Color(0xFF0D0D0D);
const Color _kSurface      = Color(0xFF1A1A1A);
const Color _kSuperStart   = Color(0xFF0F1B3D);
const Color _kSuperEnd     = Color(0xFF1A2B5C);
const Color _kSuperTitle   = Color(0xFF4F8EF7);
const Color _kPremiumStart = Color(0xFF2A1800);
const Color _kPremiumEnd   = Color(0xFF4A2C00);
const Color _kPremiumTitle = Color(0xFFC9962A);
const Color _kGold         = Color(0xFFC9962A);
const Color _kGoldLight    = Color(0xFFE8B84B);
const Color _kWhite        = Colors.white;
const Color _kMuted        = Color(0xFF9E9E9E);
const Color _kSubtle       = Color(0xFF616161);
const Color _kDivider      = Color(0xFF2A2A2A);
const Color _kPromo        = Color(0xFF1C1C2E);

// ════════════════════════════════════════════════════════════════════════════
// CARD CONFIG  — 4 dark combinations matching your palette
// ════════════════════════════════════════════════════════════════════════════

class _CardTheme {
  final Color gradStart;
  final Color gradEnd;
  final Color accent;

  const _CardTheme({
    required this.gradStart,
    required this.gradEnd,
    required this.accent,
  });
}

const _kCardThemes = [
  // 0 — Super / Blue-dark
  _CardTheme(gradStart: _kSuperStart, gradEnd: _kSuperEnd, accent: _kSuperTitle),
  // 1 — Premium / Gold-dark
  _CardTheme(gradStart: _kPremiumStart, gradEnd: _kPremiumEnd, accent: _kPremiumTitle),
  // 2 — Teal-dark
  _CardTheme(gradStart: Color(0xFF0D2020), gradEnd: Color(0xFF0D3030), accent: Color(0xFF14B8A6)),
  // 3 — Red-dark
  _CardTheme(gradStart: Color(0xFF2A0A0A), gradEnd: Color(0xFF3D1010), accent: Color(0xFFEF4444)),
];

// ════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION PLANS SCREEN — only _accentColors list changed to use themes
// ════════════════════════════════════════════════════════════════════════════

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  List<FeePlan> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await https.get(
        Uri.parse('https://playschool.edubloom.in/api/SchoolApp/viewSchoolFeePlanList'),
      );
      print("PLANS STATUS: ${response.statusCode}");
      print("PLANS BODY: ${response.body}");
      if (response.statusCode == 200) {
        final model = PlanSubscriptionModel.fromJson(jsonDecode(response.body));
        print("PLANS COUNT: ${model.data.length}");
        if (mounted) {
          setState(() { _plans = model.data; _loading = false; });
        }
      } else {
        if (mounted) {
          setState(() { _error = 'Server error: ${response.statusCode}'; _loading = false; });
        }
      }
    } catch (e) {
      print("PLANS ERROR: $e");
      if (mounted) {
        setState(() { _error = e.toString(); _loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A2847)),
          onPressed: () => Get.back(),
        ),
        title: Text('Subscription Plans',
            style: TextStyle(
                color: const Color(0xFF1A2847),
                fontSize: 18.sp,
                fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
            child: Text('Choose the plan that fits your school',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: Colors.red.shade300, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text('Failed to load plans',
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.grey.shade600)),
                  SizedBox(height: 6.h),
                  Text(_error!,
                      style: TextStyle(
                          fontSize: 11.sp, color: Colors.grey.shade400),
                      textAlign: TextAlign.center),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: _fetchPlans,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            )
                : _plans.isEmpty
                ? Center(
                child: Text('No plans available',
                    style: TextStyle(
                        fontSize: 14.sp, color: Colors.grey)))
                : ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 12.h),
              itemCount: _plans.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (ctx, i) => _SubSlideIn(
                delay: Duration(milliseconds: 80 * i),
                from: const Offset(0, 0.25),
                child: _PlanCard(
                  plan: _plans[i],
                  // ← CHANGED: theme object instead of single accentColor
                  theme: _kCardThemes[i % _kCardThemes.length],
                  isPopular: i == 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PLAN CARD  — background now uses dark gradient; text forced white;
//              baaki sab word-to-word same
// ════════════════════════════════════════════════════════════════════════════

class _PlanCard extends StatefulWidget {
  final FeePlan plan;
  final _CardTheme theme;      // ← CHANGED: was accentColor + no gradient
  final bool isPopular;
  const _PlanCard(
      {required this.plan, required this.theme, this.isPopular = false});

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _pressed = false;

  // ── helpers — unchanged ──────────────────────────────────────────────────
  List<String> get _features => widget.plan.planDescription
      .split(RegExp(r',|\r\n|\n'))
      .map((f) => f.trim())
      .where((f) => f.isNotEmpty)
      .toList();

  String get _priceDisplay {
    if (widget.plan.amount == 0 && widget.plan.discountAmount == 0) return 'Free';
    if (widget.plan.discountAmount > 0 &&
        widget.plan.discountAmount < widget.plan.amount) {
      return '₹${widget.plan.discountAmount.toStringAsFixed(0)}';
    }
    return '₹${widget.plan.amount.toStringAsFixed(0)}';
  }

  bool get _hasDiscount =>
      widget.plan.discountAmount > 0 &&
          widget.plan.discountAmount < widget.plan.amount;

  bool get _isFree =>
      widget.plan.amount == 0 && widget.plan.discountAmount == 0;

  @override
  Widget build(BuildContext context) {
    // ── shorthand for cleaner code ───────────────────────────────────────
    final accent = widget.theme.accent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          // ── CHANGED: dark gradient background ──────────────────────────
          gradient: LinearGradient(
            colors: [widget.theme.gradStart, widget.theme.gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: widget.isPopular
                ? accent
                : accent.withOpacity(0.30),            // subtle border from accent
            width: widget.isPopular ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(widget.isPopular ? 0.25 : 0.12),
              blurRadius: widget.isPopular ? 24 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── POPULAR ribbon — unchanged except uses accent ─────────────
            if (widget.isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.only(topRight: Radius.circular(22.r)),
                  child: SizedBox(
                    width: 72.w,
                    height: 72.w,
                    child: CustomPaint(
                      painter: _RibbonPainter(color: accent),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.h, right: 4.w),
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Text('POPULAR',
                                style: TextStyle(
                                    color: _kWhite,
                                    fontSize: 7.5.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Plan name + FREE badge ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.plan.planName.isNotEmpty
                              ? widget.plan.planName
                              : 'Plan',
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: _kWhite),                    // ← CHANGED
                        ),
                      ),
                      if (_isFree)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.18),  // ← CHANGED
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: Colors.green.withOpacity(0.50)),
                          ),
                          child: Text('FREE',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.greenAccent,        // ← CHANGED
                                  letterSpacing: 1)),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // ── Price row ────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_priceDisplay,
                          style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: _isFree ? Colors.greenAccent : accent, // ← CHANGED
                              height: 1)),
                      SizedBox(width: 4.w),
                      Text('/ ${widget.plan.feePlanType}',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: _kMuted)),                     // ← CHANGED
                    ],
                  ),

                  if (_hasDiscount) ...[
                    SizedBox(height: 2.h),
                    Text('₹${widget.plan.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: _kSubtle,                        // ← CHANGED
                            decoration: TextDecoration.lineThrough,
                            decorationColor: _kSubtle)),            // ← CHANGED
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),      // ← CHANGED
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Save ₹${(widget.plan.amount - widget.plan.discountAmount).toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.greenAccent,              // ← CHANGED
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],

                  SizedBox(height: 14.h),

                  // ── Feature list ─────────────────────────────────────────
                  ..._features.map((f) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.20),        // ← CHANGED
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded,
                              color: accent, size: 13.sp),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                            child: Text(f,
                                style: TextStyle(
                                    fontSize: 12.5.sp,
                                    color: _kMuted,                 // ← CHANGED
                                    fontWeight: FontWeight.w500))),
                      ],
                    ),
                  )),

                  SizedBox(height: 18.h),

                  // ── CTA button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                              () => SchoolFeePaymentScreen(
                            planId:      widget.plan.id,
                            planName:    widget.plan.planName,
                            planAmount:  widget.plan.discountAmount > 0
                                ? widget.plan.discountAmount
                                : widget.plan.amount,
                            feePlanType: widget.plan.feePlanType,
                          ),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 350),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,                    // ← CHANGED
                        foregroundColor: _kWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        _isFree ? 'Get Started Free' : 'Choose Plan',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _RibbonPainter — word-to-word same, unchanged
class _RibbonPainter extends CustomPainter {
  final Color color;
  const _RibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.30, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.70)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => false;
}