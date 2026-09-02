import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/teacher_attendance_controller.dart';
import '../models/teacher_attendance.dart';

// ======================== PREMIUM PALETTE ========================
const Color kPrimary = Color(0xFF97144D);
const Color kPrimaryDark = Color(0xFF6E0E39);
const Color kPrimaryLight = Color(0xFFC13B72);
const Color kBg = Color(0xFFF5F3F7);
const Color kSurface = Colors.white;
const Color kSuccess = Color(0xFF1E8E5A);
const Color kDanger = Color(0xFFD64545);
const Color kWarning = Color(0xFFE0A100);

// Screen ka background ab pure white — baaki sab colors same hi hain.
const Color kScreenBg = Colors.white;

// Check In = green, Check Out = dark red
const Color kCheckInGreen = Color(0xFF1E8E5A);
const Color kCheckInGreenLight = Color(0xFF43B983);
const Color kCheckOutRed = Color(0xFFB23A3A);
const Color kCheckOutRedDark = Color(0xFF7A1414);

class TeacherAttendanceView extends StatelessWidget {
  const TeacherAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherAttendanceController(), permanent: true);

    return Obx(() {
      return Scaffold(
        backgroundColor: kScreenBg,
        extendBodyBehindAppBar: false,
        // Poori screen ko RefreshIndicator mein wrap kiya hai — kahin bhi
        // pull-down karne se controller.refreshListTab() call hota hai
        // jo poora data (attendance list + status/in-out maps) dobara
        // fetch kar leta hai, chahe list UI hidden ho.
        body: RefreshIndicator(
          color: kPrimary,
          onRefresh: () => controller.refreshListTab(),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _HeaderCard(controller: controller),
                  ],
                ),
              ),
              if (controller.isPageLoading.value)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: kPrimary.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                    minHeight: 3,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ======================== HEADER CARD ========================
// Session dropdown, date field aur "Manage Attendance" button hata diya —
// ab yahan design ke mutabik logo, title, date, live clock, Teacher
// Name/Teacher Id (corners), aur In/Out Time + Check In/Out button
// dikhta hai. Attendance list ab auto-load hoti hai — pull-to-refresh
// (upar Scaffold body pe) se dobara load hoti hai.
class _HeaderCard extends StatefulWidget {
  final TeacherAttendanceController controller;
  const _HeaderCard({required this.controller});

  @override
  State<_HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<_HeaderCard> {
  late final Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _fmtClock(DateTime d) {
    final h24 = d.hour;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final ampm = h24 >= 12 ? "PM" : "AM";
    return "${h12.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')} $ampm";
  }

  // 12-hour format me "02:30 PM" dikhata hai (24-hour "14:30" nahi).
  String _fmtTime(DateTime? d) {
    if (d == null) return "--:--";
    final h24 = d.hour;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final ampm = h24 >= 12 ? "PM" : "AM";
    return "${h12.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button row
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),

          // Logo circle
          Container(
            width: 84.w,
            height: 84.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fact_check_rounded, color: Colors.white, size: 42.sp),
          ),

          SizedBox(height: 14.h),

          Text(
            "Take Attendance",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            controller.displayDateLong,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            _fmtClock(_now),
            style: TextStyle(
              color: Colors.white,
              fontSize: 27.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 18.h),

          // Teacher Name / Teacher Id (corners) + In Time / Out Time +
          // Check In/Out button — white floating card
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 18.h),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  color: Colors.black.withOpacity(.08),
                ),
              ],
            ),
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---- Teacher Name (left corner) / Teacher Id (right corner) ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("User Name",
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 11.sp)),
                            SizedBox(height: 2.h),
                            Text(
                              controller.currentTeacherName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("User Id",
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 11.sp)),
                            SizedBox(height: 2.h),
                            Text(
                              controller.currentTeacherId,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),
                  Container(height: 1, color: Colors.grey.shade200),
                  SizedBox(height: 14.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("In Time",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            _fmtTime(controller.todayInTime.value),
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w700, color: kPrimary),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 36.h, color: Colors.grey.shade300),
                      Column(
                        children: [
                          Text("Out Time",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            _fmtTime(controller.todayOutTime.value),
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w700, color: kPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  if (!controller.isCheckedOutToday.value)
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: Builder(builder: (context) {
                        final checkedIn = controller.isCheckedIn.value;
                        final saving = controller.isCheckInOutSaving.value;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: saving
                                ? LinearGradient(
                                colors: [Colors.grey.shade300, Colors.grey.shade300])
                                : LinearGradient(
                              // Check In = green, Check Out = dark red
                              colors: checkedIn
                                  ? [kCheckOutRed, kCheckOutRedDark]
                                  : [kCheckInGreenLight, kCheckInGreen],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: saving
                                ? []
                                : [
                              BoxShadow(
                                color: (checkedIn ? kCheckOutRedDark : kCheckInGreen)
                                    .withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: saving ? null : controller.handleCheckInOut,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    saving
                                        ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                        : Icon(
                                      checkedIn ? Icons.logout_rounded : Icons.login_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      saving
                                          ? "Please wait..."
                                          : (checkedIn ? "Check Out" : "Check In"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Text(
                        "Attendance completed for today",
                        style: TextStyle(
                            color: kSuccess, fontSize: 13.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ======================== LIST SECTION (kept, but not mounted) ========================
// NOTE: Ye poora section UI me mount hi nahi kiya gaya hai (TeacherAttendanceView
// ke widget tree me isko kahin call nahi kiya gaya) — sirf reference/future
// use ke liye class yahan rakhi gayi hai. Iska controller ke logic pe koi
// asar nahi padta kyunki fetchTeacherAttendanceList, refreshListTab,
// statusForUser, mapVersion waghera sab TeacherAttendanceController ke andar
// hi define hain aur Get.put(permanent: true) ki wajah se controller hamesha
// zinda rehta hai — is widget ke bina bhi.
class _ListSection extends StatelessWidget {
  final TeacherAttendanceController controller;
  const _ListSection({required this.controller});

  String _safeName(TeacherUser t) {
    final n = "${t.firstName ?? ""} ${t.lastName ?? ""}".trim();
    return n.isEmpty ? "-" : n;
  }

  String _safeReg(TeacherUser t) {
    final reg = (t.registrationNo?.trim().isNotEmpty == true)
        ? t.registrationNo!.trim()
        : t.additionalDetail?.registrationNo?.trim();
    return (reg != null && reg.isNotEmpty) ? reg : "-";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: kPrimary.withOpacity(.06),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(Icons.list_alt_rounded,
                      size: 16, color: kPrimary),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Attendance List",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: IconButton(
                      tooltip: "Refresh",
                      onPressed: controller.isViewLoading.value
                          ? null
                          : controller.refreshListTab,
                      icon: controller.isViewLoading.value
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kPrimary),
                      )
                          : const Icon(Icons.refresh_rounded,
                          color: kPrimary),
                    ),
                  );
                }),
              ],
            ),

            SizedBox(height: 10.h),

            // Table — refresh icon (upar) aur pull-to-refresh (neeche khींचke)
            // dono se controller.refreshListTab() call hota hai.
            Expanded(
              child: RefreshIndicator(
                color: kPrimary,
                onRefresh: () => controller.refreshListTab(),
                child: Obx(() {
                  if (controller.isViewLoading.value) {
                    return LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: const Center(
                            child: CircularProgressIndicator(color: kPrimary),
                          ),
                        ),
                      );
                    });
                  }

                  if (controller.teacherUsers.isEmpty) {
                    return LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(18.w),
                                  decoration: BoxDecoration(
                                    color: kBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.list_alt_rounded,
                                      size: 44, color: kPrimary.withOpacity(0.35)),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  "Pull down or tap refresh to load attendance",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() {
                        // Reading mapVersion here ensures the entire table
                        // rebuilds whenever any per-teacher map changes
                        // ignore: unused_local_variable
                        final _ = controller.mapVersion.value;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                                kPrimary.withOpacity(0.06)),
                            dataRowColor: WidgetStateProperty.resolveWith(
                                    (states) => Colors.white),
                            dividerThickness: 0.6,
                            headingTextStyle: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                              letterSpacing: 0.2,
                            ),
                            dataTextStyle: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                            ),
                            columnSpacing: 16,
                            columns: const [
                              DataColumn(label: Text("S.no")),
                              DataColumn(label: Text("Teacher Id")),
                              DataColumn(label: Text("Teacher Name")),
                              DataColumn(label: Text("Date")),
                              DataColumn(label: Text("Status")),
                            ],
                            rows: List.generate(
                              controller.teacherUsers.length,
                                  (i) {
                                final t = controller.teacherUsers[i];
                                final userId = t.userId;

                                return DataRow(
                                  color: WidgetStateProperty.resolveWith(
                                        (states) => i.isEven
                                        ? Colors.white
                                        : kBg.withOpacity(0.4),
                                  ),
                                  cells: [
                                    // S.no
                                    DataCell(Text("${i + 1}",
                                        style: TextStyle(
                                            color: Colors.grey.shade600))),

                                    // Teacher Id
                                    DataCell(Text(_safeReg(t),
                                        style:
                                        const TextStyle(fontWeight: FontWeight.w600))),

                                    // Teacher Name
                                    DataCell(Text(_safeName(t),
                                        style:
                                        const TextStyle(fontWeight: FontWeight.w600))),

                                    // Date
                                    DataCell(Text(
                                      controller.displayDate
                                          .replaceAll("/", "-"),
                                      style: TextStyle(color: Colors.grey.shade700),
                                    )),

                                    // Status — ab dropdown nahi, sirf read-only badge.
                                    // By default "Present" dikhta hai; agar auto-absent
                                    // logic ne mark kar diya ho to "Absent" dikhega.
                                    DataCell(
                                      userId == null
                                          ? const Text("-")
                                          : _StatusBadge(
                                        value: controller.statusForUser(
                                            userId, t.status),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== STATUS BADGE (read-only, no dropdown) ========================
// Pehle ye dropdown tha (Present/Absent/Holiday manually select karne ke liye).
// Ab sirf Present (default) ya Absent (auto-mark logic se) hi dikhta hai,
// koi manual selection nahi — isliye simple read-only badge.
class _StatusBadge extends StatelessWidget {
  final String? value;
  const _StatusBadge({required this.value});

  Color _colorFor(String? v) {
    if (v == TeacherAttendanceController.statusAbsent) return kDanger;
    return kSuccess; // default: Present
  }

  String _labelFor(String? v) {
    if (v == TeacherAttendanceController.statusAbsent) return "Absent";
    return "Present"; // default
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(value);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        _labelFor(value),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}