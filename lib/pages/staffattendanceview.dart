import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/staffattendancecontroller.dart';
import '../models/staff attend load model.dart';

// ======================== PREMIUM PALETTE ========================
const Color kPrimary = Color(0xFF97144D);
const Color kPrimaryDark = Color(0xFF6E0E39);
const Color kPrimaryLight = Color(0xFFC13B72);
const Color kBg = Color(0xFFF5F3F7);
const Color kSurface = Colors.white;
const Color kSuccess = Color(0xFF1E8E5A);
const Color kDanger = Color(0xFFD64545);
const Color kWarning = Color(0xFFE0A100);

const Color kScreenBg = Colors.white;

const Color kCheckInGreen = Color(0xFF1E8E5A);
const Color kCheckInGreenLight = Color(0xFF43B983);
const Color kCheckOutRed = Color(0xFFB23A3A);
const Color kCheckOutRedDark = Color(0xFF7A1414);

class Staffattendanceview extends StatelessWidget {
  const Staffattendanceview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Staffattendancecontroller(), permanent: true);

    return Obx(() {
      return Scaffold(
        backgroundColor: kScreenBg,
        extendBodyBehindAppBar: false,
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
class _HeaderCard extends StatefulWidget {
  final Staffattendancecontroller controller;
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
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

          // Staff Name / Staff Id + In/Out Time + Check In/Out button
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
                              controller.currentStaffName,
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
                              controller.currentStaffId,
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