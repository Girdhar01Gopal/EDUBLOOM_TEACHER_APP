// ============================================================
//  view_teacher_attendance_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/view_teacher_attendance_controller.dart';
import '../models/teacher_attendance_view2 model.dart';

class ViewTeacherAttendanceScreen
    extends GetView<ViewTeacherAttendanceController> {
  // ── Search state ──────────────────────────────────────────────────────────
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final TextEditingController _searchTextController = TextEditingController();

  ViewTeacherAttendanceScreen({super.key});

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

  // ── Time formatter — NO UTC conversion, API already sends IST ────────────
  // "11:21" → "11:21 AM"   |   "16:34" → "4:34 PM"
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

  // ── Status helpers ────────────────────────────────────────────────────────
  // Chhote/bade letters, space, _ , - sab hata deta hai
  // "HalfDay", "Half Day", "half_day", "half-day" sab ko match karega
  String _norm(String? s) =>
      (s ?? "").toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');

  // ✅ UPDATED: Full word (Present) aur short code (P) dono match karte hain
  bool _isPresent(String? s) {
    final v = _norm(s);
    return v == "present" || v == "p";
  }

  bool _isAbsent(String? s) {
    final v = _norm(s);
    return v == "absent" || v == "a";
  }

  bool _isHalfDay(String? s) {
    final v = _norm(s);
    return v == "halfday" || v == "hd";
  }

  bool _isLate(String? s) {
    final v = _norm(s);
    return v == "late" || v == "l";
  }

  bool _isLeave(String? s) {
    final v = _norm(s);
    return v == "leave" || v == "onleave" || v == "lv" || v == "ol";
  }

  bool _isHoliday(String? s) {
    final v = _norm(s);
    return v == "holiday" || v == "hold" || v == "h";
  }

  // ✅ Sunday check
  bool _isSunday(int year, int month, int day) =>
      DateTime(year, month, day).weekday == DateTime.sunday;

  // ✅ Agar status khaali hai aur din Sunday hai to by default Holiday
  String _effectiveStatus(String? raw, int year, int month, int day) {
    final v = (raw ?? "").trim();
    final isEmpty = v.isEmpty || v == "-";
    if (isEmpty && _isSunday(year, month, day)) return "Holiday";
    return v;
  }

  String _shortStatus(String? s) {
    if (_isPresent(s)) return "P";
    if (_isAbsent(s)) return "A";
    if (_isHoliday(s)) return "H";
    if (_isHalfDay(s)) return "HD";
    if (_isLate(s)) return "L";
    if (_isLeave(s)) return "LV";
    return "";
  }

  String _fullStatus(String? s) {
    if (_isPresent(s)) return "Present";
    if (_isAbsent(s)) return "Absent";
    if (_isHoliday(s)) return "Holiday";
    if (_isHalfDay(s)) return "Half Day";
    if (_isLate(s)) return "Late";
    if (_isLeave(s)) return "Leave";
    return "Not Available";
  }

  Color _statusColor(String? s) {
    if (_isPresent(s)) return Colors.green;
    if (_isAbsent(s)) return Colors.red;
    if (_isHoliday(s)) return Colors.purple;
    if (_isHalfDay(s)) return Colors.blue;
    if (_isLate(s)) return Colors.orange;
    if (_isLeave(s)) return Colors.teal;
    return Colors.grey.shade400;
  }

  // ── Counts (calendar data se nikalta hai, spelling tolerant) ──────────────
  int _countWhere(ViewTeacherAttendanceItem t, int days,
      bool Function(String?) test) {
    int c = 0;
    for (int d = 1; d <= days; d++) {
      if (test(t.dayStatus(d))) c++;
    }
    return c;
  }

  int _presentCount(ViewTeacherAttendanceItem t, int days) =>
      _countWhere(t, days, _isPresent);

  int _absentCount(ViewTeacherAttendanceItem t, int days) =>
      _countWhere(t, days, _isAbsent);

  // ── Half day count ────────────────────────────────────────────────────────
  int _halfDayCount(ViewTeacherAttendanceItem t, int days) =>
      _countWhere(t, days, _isHalfDay);

  // ── Late count ────────────────────────────────────────────────────────────
  int _lateCount(ViewTeacherAttendanceItem t, int days) =>
      _countWhere(t, days, _isLate);

  // ── Leave count ───────────────────────────────────────────────────────────
  int _leaveCount(ViewTeacherAttendanceItem t, int days) =>
      _countWhere(t, days, _isLeave);

  // ── Month name → number ───────────────────────────────────────────────────
  int _monthToNumber(String? m) {
    final v = (m ?? "").trim().toLowerCase();
    const map = {
      "january": 1, "jan": 1, "february": 2, "feb": 2,
      "march": 3, "mar": 3, "april": 4, "apr": 4,
      "may": 5, "june": 6, "jun": 6, "july": 7, "jul": 7,
      "august": 8, "aug": 8, "september": 9, "sep": 9, "sept": 9,
      "october": 10, "oct": 10, "november": 11, "nov": 11,
      "december": 12, "dec": 12,
    };
    return map[v] ?? DateTime.now().month;
  }

  // ── Weekday full name ─────────────────────────────────────────────────────
  String _weekdayName(int weekday) {
    const names = [
      "Monday", "Tuesday", "Wednesday", "Thursday",
      "Friday", "Saturday", "Sunday",
    ];
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
                // ── Filter card ─────────────────────────────────────────────
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
                            backgroundColor: const Color(0xFF97144D),
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

                // ── Legend ──────────────────────────────────────────────────
                _buildLegend(),

                SizedBox(height: 10.h),

                // ── Teacher cards ───────────────────────────────────────────
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
                        .where((t) =>
                        (t.name ?? "").toLowerCase().contains(query))
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
                              'No teacher found for "$query"',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    }

                    final int days = controller.daysInSelectedMonth;
                    final int year = DateTime.now().year;
                    final int month =
                    _monthToNumber(controller.selectedMonth.value);
                    final int firstWeekday = DateTime(year, month, 1).weekday;
                    // 1=Mon..6=Sat, 7=Sun → Sunday offset = 0
                    final int startOffset =
                    firstWeekday == 7 ? 0 : firstWeekday;

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ViewTeacherAttendanceItem t = filtered[index];

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
                              // ── Card Header ───────────────────────────────
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFAD1F5C),
                                      Color(0xFF6E0F39),
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
                                        (t.name?.isNotEmpty == true)
                                            ? t.name![0].toUpperCase()
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
                                            t.name ?? "No Name",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          if ((t.teacherReg ?? "").isNotEmpty)
                                            Text(
                                              t.teacherReg!,
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

                              // ── Stats ──────────────────────────────────────
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
                                          _presentCount(t, days), Colors.green),
                                    ),
                                    Expanded(
                                      child: _statChip("Absent",
                                          _absentCount(t, days), Colors.red),
                                    ),
                                    Expanded(
                                      child: _statChip("Half Day",
                                          _halfDayCount(t, days), Colors.blue),
                                    ),
                                    Expanded(
                                      child: _statChip("Late",
                                          _lateCount(t, days), Colors.orange),
                                    ),
                                    Expanded(
                                      child: _statChip("Leave",
                                          _leaveCount(t, days), Colors.teal),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFEEEEEE)),

                              // ── Calendar ───────────────────────────────────
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: _buildCalendarGrid(
                                    context, t, days, startOffset, year, month),
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
          backgroundColor: const Color(0xFF97144D),
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
              hintText: "Search teacher by name…",
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
            "View Teacher Attendance",
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

  // ── Day detail dialog ─────────────────────────────────────────────────────
  void _showDayDetailDialog(
      BuildContext context,
      ViewTeacherAttendanceItem t,
      int day,
      int year,
      int month,
      String? rawStatus,
      String? inT,
      String? outT,
      String? inAddr,
      String? outAddr,
      ) {
    final DateTime date = DateTime(year, month, day);
    final String weekday = _weekdayName(date.weekday);
    final String statusLabel = _fullStatus(rawStatus);
    final Color statusColor = _statusColor(rawStatus);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          // ✅ Chhoti screen par scroll ho jayega
          scrollable: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: statusColor.withOpacity(0.15),
                child: Icon(Icons.event, color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$weekday, $day ${_monthNameFromNumber(month)} $year",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.name ?? "No Name",
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _dialogRow("Status", statusLabel, valueColor: statusColor),
              const SizedBox(height: 8),
              _dialogRow("In Time",
                  (inT != null && inT.isNotEmpty) ? inT : "--"),
              const SizedBox(height: 8),
              _dialogRow("Out Time",
                  (outT != null && outT.isNotEmpty) ? outT : "--"),
              const SizedBox(height: 8),
              _dialogRow("In Address",
                  (inAddr != null && inAddr.isNotEmpty) ? inAddr : "--"),
              const SizedBox(height: 8),
              _dialogRow("Out Address",
                  (outAddr != null && outAddr.isNotEmpty) ? outAddr : "--"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Close",
                style: TextStyle(color: Color(0xFF97144D)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _monthNameFromNumber(int m) {
    const names = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December",
    ];
    if (m < 1 || m > 12) return "";
    return names[m - 1];
  }

  // ── Calendar grid ─────────────────────────────────────────────────────────
  Widget _buildCalendarGrid(
      BuildContext context,
      ViewTeacherAttendanceItem t,
      int daysInMonth,
      int startOffset,
      int year,
      int month,
      ) {
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
                          : const Color(0xFF97144D),
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
              // Taller cells to fit day + status + in/out time
              childAspectRatio: 0.58,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, i) {
              if (i < startOffset) return const SizedBox.shrink();

              final day = i - startOffset + 1;
              // ✅ Sunday khaali ho to by default Holiday
              final rawStatus =
              _effectiveStatus(t.dayStatus(day), year, month, day);
              final isEmpty = rawStatus.isEmpty || rawStatus == "-";
              final color =
              isEmpty ? Colors.grey.shade300 : _statusColor(rawStatus);
              final code = isEmpty ? "" : _shortStatus(rawStatus);

              // ✅ Time sirf Present, Late aur Half Day pe dikhega
              // Absent / Leave / Holiday me time hide rahega
              final showTime = !isEmpty &&
                  (_isPresent(rawStatus) ||
                      _isLate(rawStatus) ||
                      _isHalfDay(rawStatus));

              final inT = showTime ? _formatTime(t.dayIn(day)) : null;
              final outT = showTime ? _formatTime(t.dayOut(day)) : null;
              final inAddr = showTime ? t.dayInAddress(day) : null;
              final outAddr = showTime ? t.dayOutAddress(day) : null;
              final hasTime = showTime &&
                  ((inT != null && inT.isNotEmpty) ||
                      (outT != null && outT.isNotEmpty));

              return GestureDetector(
                onTap: () => _showDayDetailDialog(context, t, day, year, month,
                    rawStatus, inT, outT, inAddr, outAddr),
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
                  padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
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

  // ── Legend ────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
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