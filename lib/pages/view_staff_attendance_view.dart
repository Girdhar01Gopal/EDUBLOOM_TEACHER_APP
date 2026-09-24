// ============================================================
//  view_staff_attendance_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/view_staff_attendance_controller.dart';
import '../models/view staff attendance details.dart';

// ── Maroon swatch (replaces Colors.teal everywhere in this file) ───────────
const MaterialColor maroon = MaterialColor(0xFF800000, <int, Color>{
  600: Color(0xFF97144D),
  700: Color(0xFFC2185B),
  800: Color(0xFF97144D),
  900: Color(0xFFC2185B),
});

class ViewStaffAttendanceScreen
    extends GetView<ViewStaffAttendanceController> {
  // ── Search state ──────────────────────────────────────────────────────────
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final TextEditingController _searchTextController = TextEditingController();

  ViewStaffAttendanceScreen({super.key});

  // ── Input decoration ──────────────────────────────────────────────────────
  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  // ── Time formatter — API already sends IST, NO UTC offset ────────────────
  // "11:21" → "11:21 AM"  |  "16:34" → "4:34 PM"
  String _formatTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "";
    try {
      final parts = raw.trim().split(":");
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final period = h < 12 ? "AM" : "PM";
        final h12 = h % 12 == 0 ? 12 : h % 12;
        return "$h12:${m.toString().padLeft(2, '0')} $period";
      }
    } catch (_) {}
    return raw.trim();
  }

  // ── Normalizer: chhote/bade/space/_/- sab hata deta hai ─────────────────
  String _norm(String? s) =>
      (s ?? "").toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');

  // ── Present / Absent helpers ─────────────────────────────────────────────
  // ✅ UPDATED: Full word (Present) aur short code (P) dono match karte hain
  bool _isPresent(String? s) {
    final v = _norm(s);
    return v == "present" || v == "p";
  }

  bool _isAbsent(String? s) {
    final v = _norm(s);
    return v == "absent" || v == "a";
  }

  // ── Half Day helpers ──────────────────────────────────────────────────────
  // ✅ "HalfDay" / "Half Day" / "half_day" / "half-day" / "HD" sab handle honge
  bool _isHalfDay(String? s) {
    final v = _norm(s);
    return v == "halfday" || v == "hd";
  }

  // ✅ month me kitne Half Day hain (status se count hota hai)
  int _halfDayCount(StaffAttendanceView staff, int daysInMonth) {
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (_isHalfDay(staff.attendanceStatus(d))) count++;
    }
    return count;
  }

  // ── Late helpers ─────────────────────────────────────────────────────────
  // ✅ "Late" / "late" / " Late " / "L" sab handle honge
  bool _isLate(String? s) {
    final v = _norm(s);
    return v == "late" || v == "l";
  }

  // ✅ month me kitne Late hain (status se count hota hai)
  int _lateCount(StaffAttendanceView staff, int daysInMonth) {
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (_isLate(staff.attendanceStatus(d))) count++;
    }
    return count;
  }

  // ── Leave helpers ────────────────────────────────────────────────────────
  // ✅ "Leave" / "LEAVE" / "leave" / " Leave " / "on_leave" / "LV" sab handle honge
  bool _isLeave(String? s) {
    final v = _norm(s);
    return v == "leave" || v == "onleave" || v == "lv" || v == "ol";
  }

  // ✅ month me kitne Leave hain (status se count hota hai)
  int _leaveCount(StaffAttendanceView staff, int daysInMonth) {
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (_isLeave(staff.attendanceStatus(d))) count++;
    }
    return count;
  }

  // ── Holiday helpers ──────────────────────────────────────────────────────
  // ✅ "Holiday" / "HOLIDAY" / "hold" / "H" sab handle honge
  bool _isHoliday(String? s) {
    final v = _norm(s);
    return v == "holiday" || v == "hold" || v == "h";
  }

  // ✅ Sunday check
  bool _isSunday(int year, int month, int day) =>
      DateTime(year, month, day).weekday == DateTime.sunday;

  // ✅ Agar status khaali hai aur din Sunday hai to by default Holiday
  String _effectiveStatus(String raw, int year, int month, int day) {
    final v = raw.trim();
    final isEmpty = v.isEmpty || v == "-";
    if (isEmpty && _isSunday(year, month, day)) return "Holiday";
    return raw;
  }

  // ── Status helpers ────────────────────────────────────────────────────────
  String _shortStatus(String? s) {
    if (_isPresent(s)) return "P";
    if (_isAbsent(s)) return "A";
    if (_isHoliday(s)) return "H";
    if (_isHalfDay(s)) return "HD";
    if (_isLate(s)) return "L";
    if (_isLeave(s)) return "LV";
    return "";
  }

  Color _statusColor(String? s) {
    if (_isPresent(s)) return Colors.green;
    if (_isAbsent(s)) return Colors.red;
    if (_isHoliday(s)) return Colors.purple;
    if (_isHalfDay(s)) return Colors.blue;
    if (_isLate(s)) return Colors.orange;
    if (_isLeave(s)) return Colors.teal;
    return Colors.grey.shade300;
  }

  // ── Month number → full name ──────────────────────────────────────────────
  String _monthName(int m) {
    const names = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return (m >= 1 && m <= 12) ? names[m - 1] : "";
  }

  // ── Weekday name for a given date ─────────────────────────────────────────
  String _weekdayName(int year, int month, int day) {
    const names = [
      "Monday", "Tuesday", "Wednesday", "Thursday",
      "Friday", "Saturday", "Sunday"
    ];
    final weekday = DateTime(year, month, day).weekday; // 1 = Monday
    return names[weekday - 1];
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      // ✅ Responsive: bade screen (tablet) par content center me rahega
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // ── Filter card ───────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedMonth.value,
                        isExpanded: true,
                        items: controller.months
                            .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: controller.setMonth,
                        decoration: _dec("Month *"),
                      )),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.fetchReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon.shade800,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : Text(
                            "Show Report",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ── Legend ────────────────────────────────────────────────
                _buildLegend(),

                SizedBox(height: 10.h),

                // ── Staff cards ───────────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.reportList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "No Attendance Found",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    }

                    // Search filter
                    final query = _searchQuery.value.trim().toLowerCase();
                    final filtered = query.isEmpty
                        ? controller.reportList
                        : controller.reportList
                        .where((s) =>
                        s.name.toLowerCase().contains(query))
                        .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No staff found for "$query"',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    }

                    final int days = controller.daysInSelectedMonth;
                    final int year = controller.selectedYear.value;
                    final int month = controller.monthIndex;
                    final int firstWeekday = DateTime(year, month, 1).weekday;
                    final int startOffset =
                    firstWeekday == 7 ? 0 : firstWeekday;

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final StaffAttendanceView staff = filtered[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Card Header ─────────────────────────────
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      maroon.shade600,
                                      maroon.shade900,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                      child: Text(
                                        staff.name.isNotEmpty
                                            ? staff.name[0].toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff.name.isEmpty
                                                ? "No Name"
                                                : staff.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          if (staff.staffReg.isNotEmpty)
                                            Text(
                                              staff.staffReg,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── Stats ────────────────────────────────────
                              // ✅ Present / Absent / Half Day / Late / Leave
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: _statChip("Present",
                                          staff.presentCount, Colors.green),
                                    ),
                                    Expanded(
                                      child: _statChip("Absent",
                                          staff.absentCount, Colors.red),
                                    ),
                                    Expanded(
                                      child: _statChip(
                                          "Half Day",
                                          _halfDayCount(staff, days),
                                          Colors.blue),
                                    ),
                                    Expanded(
                                      child: _statChip(
                                          "Late",
                                          _lateCount(staff, days),
                                          Colors.orange),
                                    ),
                                    // ✅ Leave
                                    Expanded(
                                      child: _statChip(
                                          "Leave",
                                          _leaveCount(staff, days),
                                          Colors.teal),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFEEEEEE)),

                              // ── Calendar ─────────────────────────────────
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: _buildCalendarGrid(context, staff, days,
                                    startOffset, year, month),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar with search ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final searching = _isSearching.value;
        return AppBar(
          backgroundColor: maroon.shade800,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (searching) {
                _isSearching.value = false;
                _searchQuery.value = '';
                _searchTextController.clear();
              } else {
                Get.back();
              }
            },
          ),
          title: searching
              ? TextField(
            controller: _searchTextController,
            autofocus: true,
            onChanged: (v) => _searchQuery.value = v,
            style:
            const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: "Search staff by name…",
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14),
              border: InputBorder.none,
              suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  _searchQuery.value = '';
                  _searchTextController.clear();
                },
                child: const Icon(Icons.close,
                    color: Colors.white, size: 20),
              )
                  : const SizedBox.shrink()),
            ),
          )
              : const Text(
            "View Staff Attendance",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          actions: [
            Obx(() {
              if (_isSearching.value) return const SizedBox.shrink();
              if (controller.reportList.isEmpty)
                return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                tooltip: "Search by name",
                onPressed: () => _isSearching.value = true,
              );
            }),
          ],
        );
      }),
    );
  }

  // ── Calendar grid ─────────────────────────────────────────────────────────
  Widget _buildCalendarGrid(BuildContext context, StaffAttendanceView staff,
      int daysInMonth, int startOffset, int year, int month) {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // ✅ Responsive: cell ki width ke hisaab se font scale hoga
    return LayoutBuilder(builder: (context, constraints) {
      const double spacing = 3;
      final double cellW = (constraints.maxWidth - spacing * 6) / 7;
      // 40.8 = ~360px wide phone par cell width (original design)
      final double scale = (cellW / 40.8).clamp(0.85, 1.8);

      return Column(
        children: [
          // Day-of-week header
          Row(
            children: List.generate(
              7,
                  (i) => Expanded(
                child: Center(
                  child: Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: (i == 0 || i == 6)
                          ? Colors.red.shade400
                          : maroon.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              // Taller to fit day + P/A/HD/L/LV/H + in/out time
              childAspectRatio: 0.58,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, i) {
              if (i < startOffset) return const SizedBox.shrink();

              final day = i - startOffset + 1;
              // ✅ Sunday khaali ho to by default Holiday
              final rawStatus = _effectiveStatus(
                  staff.attendanceStatus(day), year, month, day);
              final isEmpty = rawStatus.isEmpty || rawStatus == "-";
              final color = _statusColor(rawStatus);
              final code = isEmpty ? "" : _shortStatus(rawStatus);

              // Time Present, Late aur HalfDay teeno status pe dikhega,
              // Absent / Leave / Holiday me time hide rahega
              final isPresent = _isPresent(rawStatus); // ✅ UPDATED (P bhi chalega)
              final isLateStatus = _isLate(rawStatus);
              final isHalfDayStatus = _isHalfDay(rawStatus);
              final showTime = isPresent || isLateStatus || isHalfDayStatus;

              final inT = showTime ? _formatTime(staff.dayIn(day)) : null;
              final outT = showTime ? _formatTime(staff.dayOut(day)) : null;
              final inAddr = showTime ? staff.dayInAddress(day) : null;
              final outAddr = showTime ? staff.dayOutAddress(day) : null;
              final hasTime = showTime &&
                  ((inT != null && inT.isNotEmpty) ||
                      (outT != null && outT.isNotEmpty));

              return GestureDetector(
                onTap: () => _showDayDetailDialog(
                  context: context,
                  staffName: staff.name,
                  day: day,
                  month: month,
                  year: year,
                  status: rawStatus,
                  inTime: inT,
                  outTime: outT,
                  inAddress: inAddr,
                  outAddress: outAddr,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isEmpty
                        ? null
                        : [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 2, horizontal: 1),
                  // ✅ FittedBox: kisi bhi screen / text scale par overflow nahi
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day number
                        Text(
                          "$day",
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.bold,
                            color: isEmpty ? Colors.black38 : Colors.white,
                          ),
                        ),
                        // Status code P / A / HD / L / LV / H
                        if (code.isNotEmpty)
                          Text(
                            code,
                            style: TextStyle(
                                fontSize: 9 * scale,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        // In time
                        if (hasTime && inT != null && inT.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            inT,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 6 * scale,
                                color: Colors.white,
                                height: 1.1),
                          ),
                        ],
                        // Out time
                        if (hasTime && outT != null && outT.isNotEmpty)
                          Text(
                            outT,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 6 * scale,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.1),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // ── Day detail dialog ─────────────────────────────────────────────────────
  void _showDayDetailDialog({
    required BuildContext context,
    required String? staffName,
    required int day,
    required int month,
    required int year,
    required String? status,
    required String? inTime,
    required String? outTime,
    required String? inAddress,
    required String? outAddress,
  }) {
    // ✅ UPDATED: short code (P, A, HD...) ko bhi proper naam se dikhayega
    final statusText = (status == null || status.trim().isEmpty)
        ? "N/A"
        : _isPresent(status)
        ? "Present"
        : _isAbsent(status)
        ? "Absent"
        : _isHalfDay(status)
        ? "Half Day"
        : _isLate(status)
        ? "Late"
        : _isLeave(status)
        ? "Leave"
        : _isHoliday(status)
        ? "Holiday"
        : status.trim();
    final color = _statusColor(status);
    final weekday = _weekdayName(year, month, day);
    final monthName = _monthName(month);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        // ✅ Chhoti screen par scroll ho jayega
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon + full date ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "$weekday, $day $monthName $year",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if ((staffName ?? "").isNotEmpty) ...[
                Text(
                  staffName!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _dialogRow("Status", statusText, valueColor: color, bold: true),
              const SizedBox(height: 12),
              _dialogRow("In Time",
                  (inTime == null || inTime.isEmpty) ? "--" : inTime),
              const SizedBox(height: 12),
              _dialogRow("Out Time",
                  (outTime == null || outTime.isEmpty) ? "--" : outTime),
              const SizedBox(height: 12),
              _dialogRow("In Address",
                  (inAddress == null || inAddress.isEmpty) ? "--" : inAddress),
              const SizedBox(height: 12),
              _dialogRow(
                  "Out Address",
                  (outAddress == null || outAddress.isEmpty)
                      ? "--"
                      : outAddress),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: maroon.shade900,
            ),
            child: const Text(
              "Close",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor ?? Colors.black87,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Legend ────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        _legendDot(Colors.green, "Present"),
        _legendDot(Colors.red, "Absent"),
        _legendDot(Colors.purple, "Holiday"),
        _legendDot(Colors.blue, "Half Day"),
        _legendDot(Colors.orange, "Late"),
        _legendDot(Colors.teal, "Leave"),
        _legendDot(Colors.grey.shade300, "N/A"),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  // ── Stat chip ─────────────────────────────────────────────────────────────
  // ✅ Responsive: 5 chips ek row me fit ho jayein, isliye FittedBox
  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
              style:
              const TextStyle(fontSize: 10, color: Colors.black54)),
        ),
      ],
    );
  }
}