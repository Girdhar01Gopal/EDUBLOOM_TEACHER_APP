import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ════════════════════════════════════════════════════════════════════════════
// THEME CONSTANTS
// ════════════════════════════════════════════════════════════════════════════

const Color _kPrimary     = Color(0xFF00695C); // teal 800
const Color _kAccent      = Color(0xFF00897B); // teal 600
const Color _kBg          = Colors.white;
const Color _kSurface     = Colors.white;
const Color _kText        = Color(0xFF1A1A1A);
const Color _kTextSub     = Color(0xFF555555);
const Color _kGreen       = Color(0xFF2E7D32);
const Color _kOrange      = Color(0xFFE65100);
const Color _kGold        = Color(0xFFC9962A);
const Color _kGoldLight   = Color(0xFFE8B84B);
const Color _kYellow      = Color(0xFFFFF8E1); // amber 50 bg for badge

// Duration multipliers
const Map<String, double> _kMultipliers = {
  'Monthly'    : 1.0,
  'Quarterly'  : 3.0,
  'Half Yearly': 6.0,
  'Yearly'     : 12.0,
};

// ════════════════════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════════════════════

class FeePaymentRecord {
  final int id;
  final String payDate;
  final String planName;
  final String duration;
  final String couponCode;
  final String discountPercent;
  final double discountAmount;
  final double finalAmount;
  final String receiptNo;
  final String session;

  const FeePaymentRecord({
    required this.id,
    required this.payDate,
    required this.planName,
    required this.duration,
    required this.couponCode,
    required this.discountPercent,
    required this.discountAmount,
    required this.finalAmount,
    required this.receiptNo,
    required this.session,
  });

  factory FeePaymentRecord.fromJson(Map<String, dynamic> j) => FeePaymentRecord(
    id: j['id'] ?? 0,
    payDate: j['payDate'] ?? '',
    planName: j['planName'] ?? '',
    duration: j['duration'] ?? '',
    couponCode: j['couponCode'] ?? '',
    discountPercent: j['discountPercent']?.toString() ?? '0.00 %',
    discountAmount: (j['discountAmount'] as num?)?.toDouble() ?? 0.0,
    finalAmount: (j['finalAmount'] as num?)?.toDouble() ?? 0.0,
    receiptNo: j['receiptNo'] ?? '',
    session: j['session'] ?? '',
  );
}

// ════════════════════════════════════════════════════════════════════════════
// DUMMY DATA
// ════════════════════════════════════════════════════════════════════════════

List<FeePaymentRecord> _dummyHistory() => [
  const FeePaymentRecord(
    id: 1,
    payDate: '03-Jun-2026',
    planName: 'Starter',
    duration: 'Half Yearly',
    couponCode: '',
    discountPercent: '0.00 %',
    discountAmount: 0.0,
    finalAmount: 5500.0,
    receiptNo: 'TPS002',
    session: '2026-27',
  ),
  const FeePaymentRecord(
    id: 2,
    payDate: '02-Jun-2026',
    planName: 'Free',
    duration: 'Monthly',
    couponCode: 'SAVE10',
    discountPercent: '10.00 %',
    discountAmount: 200.0,
    finalAmount: 1800.0,
    receiptNo: 'TPS001',
    session: '2026-27',
  ),
];

// ════════════════════════════════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════════════════════════════════

class SchoolFeePaymentScreen extends StatefulWidget {
  final int planId;
  final String planName;
  final double planAmount;   // base monthly amount
  final String feePlanType;

  const SchoolFeePaymentScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.planAmount,
    required this.feePlanType,
  });

  @override
  State<SchoolFeePaymentScreen> createState() =>
      _SchoolFeePaymentScreenState();
}

class _SchoolFeePaymentScreenState extends State<SchoolFeePaymentScreen>
    with SingleTickerProviderStateMixin {

  // ── duration dropdown ─────────────────────────────────────────────────────
  final List<String> _durations = ['Monthly', 'Quarterly', 'Half Yearly', 'Yearly'];
  late String _selectedDuration;

  // ── controllers ───────────────────────────────────────────────────────────
  final _couponCtrl        = TextEditingController();
  final _payDateCtrl       = TextEditingController();
  final _discountPctCtrl   = TextEditingController(text: '0');
  final _discountAmtCtrl   = TextEditingController(text: '0');

  // ── computed values ───────────────────────────────────────────────────────
  double get _baseMonthly  => widget.planAmount;
  double get _planAmount   => _baseMonthly * (_kMultipliers[_selectedDuration] ?? 1.0);
  double _discountPercent  = 0;
  double _discountAmount   = 0;
  double _finalAmount      = 0;

  // ── state ─────────────────────────────────────────────────────────────────
  bool _saving             = false;
  bool _applyingCoupon     = false;
  bool _loadingHistory     = true;
  List<FeePaymentRecord> _history = [];

  // ── shared scroll controller for synchronized table scroll ────────────────
  final ScrollController _tableScrollCtrl = ScrollController();

  // ── animation ─────────────────────────────────────────────────────────────
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  static const _base = 'https://playschool.edubloom.in/api/SchoolApp';

  @override
  void initState() {
    super.initState();
    _selectedDuration = _durations.contains(widget.feePlanType)
        ? widget.feePlanType
        : _durations[0];
    _finalAmount = _planAmount;
    _payDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    _animCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();

    _loadHistory();
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    _payDateCtrl.dispose();
    _discountPctCtrl.dispose();
    _discountAmtCtrl.dispose();
    _tableScrollCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── recalculate amounts when duration changes ─────────────────────────────
  void _onDurationChanged(String? v) {
    if (v == null) return;
    setState(() {
      _selectedDuration = v;
      _recalculate();
    });
  }

  void _recalculate() {
    final pct = double.tryParse(_discountPctCtrl.text) ?? 0.0;
    _discountPercent = pct;
    _discountAmount  = _planAmount * pct / 100.0;
    _discountAmtCtrl.text = _discountAmount.toStringAsFixed(2);
    _finalAmount = _planAmount - _discountAmount;
  }

  void _onDiscountPctChanged(String val) {
    final pct = double.tryParse(val) ?? 0.0;
    setState(() {
      _discountPercent = pct;
      _discountAmount  = _planAmount * pct / 100.0;
      _discountAmtCtrl.text = _discountAmount.toStringAsFixed(2);
      _finalAmount = _planAmount - _discountAmount;
    });
  }

  void _onDiscountAmtChanged(String val) {
    final amt = double.tryParse(val) ?? 0.0;
    setState(() {
      _discountAmount  = amt;
      _discountPercent = _planAmount > 0 ? (amt / _planAmount * 100.0) : 0.0;
      _finalAmount = _planAmount - _discountAmount;
    });
  }

  // ── load history ──────────────────────────────────────────────────────────
  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final res = await http.get(
        Uri.parse('$_base/viewSchoolFeePaymentList?planId=${widget.planId}'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final list = (json['data'] as List? ?? [])
            .map((x) => FeePaymentRecord.fromJson(x))
            .toList();
        if (mounted) setState(() { _history = list; _loadingHistory = false; });
        return;
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() { _history = _dummyHistory(); _loadingHistory = false; });
  }

  // ── apply coupon ──────────────────────────────────────────────────────────
  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _applyingCoupon = true);
    try {
      final res = await http.get(
        Uri.parse('$_base/applyCoupon?couponCode=$code&planId=${widget.planId}&amount=$_planAmount'),
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['isSuccess'] == true) {
          setState(() {
            _discountPercent = (data['discountPercent'] as num?)?.toDouble() ?? 0.0;
            _discountAmount  = (data['discountAmount']  as num?)?.toDouble() ?? 0.0;
            _finalAmount     = (data['finalAmount']      as num?)?.toDouble() ?? _planAmount;
            _discountPctCtrl.text = _discountPercent.toStringAsFixed(2);
            _discountAmtCtrl.text = _discountAmount.toStringAsFixed(2);
          });
          _snack('Coupon applied successfully!', _kGreen);
          if (mounted) setState(() => _applyingCoupon = false);
          return;
        }
      }
    } catch (_) {}
    // demo: SAVE10 = 10%
    if (code.toUpperCase() == 'SAVE10') {
      final disc = _planAmount * 0.10;
      setState(() {
        _discountPercent = 10;
        _discountAmount  = disc;
        _finalAmount     = _planAmount - disc;
        _discountPctCtrl.text = '10';
        _discountAmtCtrl.text = disc.toStringAsFixed(2);
        _applyingCoupon = false;
      });
      _snack('Coupon SAVE10 applied! 10% off', _kGreen);
    } else {
      _snack('Invalid coupon code', Colors.red.shade700);
      if (mounted) setState(() => _applyingCoupon = false);
    }
  }

  // ── save payment ──────────────────────────────────────────────────────────
  Future<void> _savePayment() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _snack('Payment saved successfully!', _kGreen);
      setState(() {
        _history.insert(
          0,
          FeePaymentRecord(
            id: _history.length + 1,
            payDate: _payDateCtrl.text,
            planName: widget.planName,
            duration: _selectedDuration,
            couponCode: _couponCtrl.text.trim(),
            discountPercent: '${_discountPercent.toStringAsFixed(2)} %',
            discountAmount: _discountAmount,
            finalAmount: _finalAmount,
            receiptNo: 'TPS${(_history.length + 1).toString().padLeft(3, '0')}',
            session: '2026-27',
          ),
        );
        _saving = false;
      });
    }
  }

  void _snack(String msg, Color color) => Get.snackbar(
    '',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: color,
    colorText: Colors.white,
    margin: EdgeInsets.all(14.r),
    borderRadius: 12.r,
    duration: const Duration(seconds: 3),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _appBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _planBadge(),
                SizedBox(height: 16.h),
                _formCard(),
                SizedBox(height: 24.h),
                _sectionLabel('Payment History'),
                SizedBox(height: 10.h),
                _historyCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: const Color(0xFF00695C), // teal 800
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
      onPressed: () => Get.back(),
    ),
    title: Text(
      'School Fee Payment',
      style: TextStyle(
          color: Colors.white,
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(3),
      child: Container(
        height: 3,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF80CBC4), Color(0xFF26A69A), Color(0xFF00897B)],
          ),
        ),
      ),
    ),
  );

  // ── Plan badge (yellow theme) ─────────────────────────────────────────────

  Widget _planBadge() => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1), // amber 50
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: _kGold.withOpacity(0.35)),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: _kGold,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.planName,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7B5000)),
              ),
              Text(
                '₹${widget.planAmount.toStringAsFixed(0)}/mo  •  ${widget.feePlanType}',
                style: TextStyle(fontSize: 11.sp, color: _kGold),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: _kGold.withOpacity(0.5)),
          ),
          child: Text(
            'ACTIVE',
            style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: _kGold,
                letterSpacing: 0.8),
          ),
        ),
      ],
    ),
  );

  // ── Form card (light golden header, black/white body) ─────────────────────

  Widget _formCard() => Container(
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: _kGold.withOpacity(0.20)),
      boxShadow: [
        BoxShadow(
          color: _kGold.withOpacity(0.10),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header strip — light golden
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            border: Border(
                bottom: BorderSide(color: _kGold.withOpacity(0.25), width: 1)),
          ),
          child: Row(
            children: [
              Icon(Icons.payment_rounded, color: _kGold, size: 17.sp),
              SizedBox(width: 8.w),
              Text(
                'Payment Details',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7B5000)),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(18.r),
          child: Column(
            children: [
              // Row 1: Duration | Plan Amount | Coupon Code
              Row(children: [
                Expanded(child: _durationDropdown()),
                SizedBox(width: 12.w),
                Expanded(child: _readField('Plan Amount',
                    '₹${_planAmount.toStringAsFixed(0)}')),
                SizedBox(width: 12.w),
                Expanded(child: _couponField()),
              ]),
              SizedBox(height: 14.h),
              // Row 2: Discount % | Discount Amount | Final Amount
              Row(children: [
                Expanded(child: _discountPctField()),
                SizedBox(width: 12.w),
                Expanded(child: _discountAmtField()),
                SizedBox(width: 12.w),
                Expanded(child: _readField('Final Amount',
                    '₹${_finalAmount.toStringAsFixed(0)}',
                    highlight: true)),
              ]),
              SizedBox(height: 14.h),
              // Pay Date (half width — ensures dd-MM-yyyy fully visible)
              Row(children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 68.w) / 2,
                  child: _dateField(),
                ),
              ]),
              SizedBox(height: 22.h),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _saving ? null : _savePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.r)),
                    disabledBackgroundColor: _kGreen.withOpacity(0.5),
                  ),
                  child: _saving
                      ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 18),
                      SizedBox(width: 8.w),
                      Text('Save Payment',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Duration Dropdown ─────────────────────────────────────────────────────

  Widget _durationDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl('Duration'),
      SizedBox(height: 6.h),
      Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedDuration,
            isExpanded: true,
            icon: Icon(Icons.expand_more_rounded,
                color: _kText, size: 18.sp),
            dropdownColor: Colors.white,
            style: TextStyle(
                fontSize: 12.sp,
                color: _kText,
                fontWeight: FontWeight.w600),
            items: _durations
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: _onDurationChanged,
          ),
        ),
      ),
    ],
  );

  // ── Read-only field ───────────────────────────────────────────────────────

  Widget _readField(String label, String value, {bool highlight = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lbl(label),
          SizedBox(height: 6.h),
          Container(
            height: 44.h,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: highlight
                  ? const Color(0xFFFFF8E1)
                  : const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: highlight
                      ? _kGold.withOpacity(0.50)
                      : Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight:
                  highlight ? FontWeight.w800 : FontWeight.w600,
                  color: highlight ? _kGold : _kText),
            ),
          ),
        ],
      );

  // ── Editable Discount % field ─────────────────────────────────────────────

  Widget _discountPctField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl('Discount %'),
      SizedBox(height: 6.h),
      SizedBox(
        height: 44.h,
        child: TextField(
          controller: _discountPctCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
              fontSize: 12.sp, color: _kText, fontWeight: FontWeight.w600),
          decoration: _editDecor(hint: 'e.g. 10'),
          onChanged: _onDiscountPctChanged,
        ),
      ),
    ],
  );

  // ── Editable Discount Amount field ────────────────────────────────────────

  Widget _discountAmtField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl('Discount Amount'),
      SizedBox(height: 6.h),
      SizedBox(
        height: 44.h,
        child: TextField(
          controller: _discountAmtCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
              fontSize: 12.sp, color: _kText, fontWeight: FontWeight.w600),
          decoration: _editDecor(hint: 'e.g. 500', prefix: '₹ '),
          onChanged: _onDiscountAmtChanged,
        ),
      ),
    ],
  );

  InputDecoration _editDecor({String hint = '', String prefix = ''}) =>
      InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        prefixText: prefix,
        prefixStyle: TextStyle(
            fontSize: 12.sp, color: _kText, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide:
            BorderSide(color: Colors.grey.shade300, width: 1.2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide:
            BorderSide(color: Colors.grey.shade300, width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: _kAccent, width: 1.8)),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
      );

  // ── Coupon field ──────────────────────────────────────────────────────────

  Widget _couponField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl('Coupon Code'),
      SizedBox(height: 6.h),
      SizedBox(
        height: 44.h,
        child: TextField(
          controller: _couponCtrl,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(
              fontSize: 12.sp,
              color: _kText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
          decoration: InputDecoration(
            contentPadding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                BorderSide(color: Colors.grey.shade300, width: 1.2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                BorderSide(color: Colors.grey.shade300, width: 1.2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: _kAccent, width: 1.8)),
            hintText: 'e.g. SAVE10',
            hintStyle: TextStyle(
                fontSize: 11.sp, color: Colors.grey.shade400),
            suffixIcon: _applyingCoupon
                ? Padding(
              padding: EdgeInsets.all(11.r),
              child: SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF00695C)),
              ),
            )
                : IconButton(
              icon: Icon(Icons.check_circle_rounded,
                  color: _kGreen, size: 19.sp),
              onPressed: _applyCoupon,
              tooltip: 'Apply',
            ),
          ),
          onSubmitted: (_) => _applyCoupon(),
        ),
      ),
    ],
  );

  // ── Date field (fixed — full dd-MM-yyyy always visible) ──────────────────

  Widget _dateField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl('Pay Date'),
      SizedBox(height: 6.h),
      TextField(
        controller: _payDateCtrl,
        readOnly: true,
        style: TextStyle(
            fontSize: 13.sp,
            color: _kText,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: false,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
              BorderSide(color: Colors.grey.shade300, width: 1.2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
              BorderSide(color: Colors.grey.shade300, width: 1.2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: _kAccent, width: 1.8)),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 4.w),
            child:
            Icon(Icons.event_rounded, color: _kPrimary, size: 18.sp),
          ),
          suffixIconConstraints:
          BoxConstraints(minWidth: 36.w, minHeight: 36.h),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(
                    primary: Color(0xFF00695C)),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            _payDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
          }
        },
      ),
    ],
  );

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
              color: _kGold,
              borderRadius: BorderRadius.circular(4.r))),
      SizedBox(width: 8.w),
      Text(text,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: _kText)),
    ],
  );

  // ── History card with SINGLE synchronized scroll ──────────────────────────

  Widget _historyCard() => Container(
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Column(
        children: [
          if (_loadingHistory)
            Padding(
              padding: EdgeInsets.all(36.r),
              child: const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF00695C))),
            )
          else if (_history.isEmpty)
            Padding(
              padding: EdgeInsets.all(28.r),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: Colors.grey.shade300, size: 40.sp),
                    SizedBox(height: 8.h),
                    Text('No payment records',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
          // ── Single horizontal scroll wraps BOTH header + rows ──
            SingleChildScrollView(
              controller: _tableScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    color: _kPrimary,
                    child: _tableHeader(),
                  ),
                  // Rows
                  ...List.generate(_history.length, (i) {
                    final r = _history[i];
                    final even = i % 2 == 0;
                    return Container(
                      color: even
                          ? Colors.white
                          : const Color(0xFFF5F5F5),
                      child: Column(
                        children: [
                          _tableRow(r, i),
                          if (i < _history.length - 1)
                            Divider(
                                height: 1,
                                color: Colors.grey.shade200),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  // ── Table header ──────────────────────────────────────────────────────────

  Widget _tableHeader() {
    final cols = [
      _ColDef('S.No',         48.w),
      _ColDef('Pay Date',     100.w),
      _ColDef('Plan Name',    92.w),
      _ColDef('Duration',     96.w),
      _ColDef('Coupon Code',  100.w),
      _ColDef('Discount %',   88.w),
      _ColDef('Disc. Amount', 104.w),
      _ColDef('Final Amount', 104.w),
      _ColDef('Receipt No',   90.w),
      _ColDef('Session',      80.w),
      _ColDef('Action',       82.w),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        children: cols
            .map((c) => SizedBox(
          width: c.width,
          child: Text(c.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2)),
        ))
            .toList(),
      ),
    );
  }

  // ── Table row ─────────────────────────────────────────────────────────────

  Widget _tableRow(FeePaymentRecord r, int i) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          _cell('${i + 1}',   48.w,  bold: false, muted: true),
          _cell(r.payDate,    100.w),
          _cell(r.planName,   92.w,  bold: true),
          _cell(r.duration,   96.w),
          _cell(r.couponCode.isEmpty ? '—' : r.couponCode, 100.w,
              color: r.couponCode.isEmpty ? null : _kOrange),
          _cell(r.discountPercent, 88.w),
          _cell('₹ ${r.discountAmount.toStringAsFixed(2)}', 104.w),
          _cell('₹ ${r.finalAmount.toStringAsFixed(2)}',   104.w,
              bold: true, color: _kGreen),
          _cell(r.receiptNo,  90.w,  bold: true, color: _kPrimary),
          _cell(r.session,    80.w),
          // Print button
          SizedBox(
            width: 82.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: ElevatedButton.icon(
                onPressed: () => _printReceipt(r),
                icon: Icon(Icons.print_rounded, size: 11.sp),
                label: Text('Print',
                    style: TextStyle(
                        fontSize: 10.sp, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.w, vertical: 6.h),
                  minimumSize: Size(68.w, 30.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, double width,
      {bool bold = false, bool muted = false, Color? color}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color ??
              (muted ? Colors.grey.shade500 : const Color(0xFF263238)),
        ),
      ),
    );
  }

  void _printReceipt(FeePaymentRecord r) {
    Get.snackbar(
      'Print Receipt',
      'Generating receipt: ${r.receiptNo}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _kPrimary,
      colorText: Colors.white,
      margin: EdgeInsets.all(14.r),
      borderRadius: 12.r,
      icon: const Icon(Icons.print_rounded, color: Colors.white),
    );
  }

  Widget _lbl(String text) => Text(text,
      style: TextStyle(
          fontSize: 10.5.sp,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500));
}

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════

class _ColDef {
  final String label;
  final double width;
  const _ColDef(this.label, this.width);
}