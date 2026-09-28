import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/daycareattendancecontroller2.dart';

// ─── Palette (Axis Bank theme) ─────────────
const _teal = Color(0xFF97144D);
const _tealLight = Color(0xFFAE275F);
const _tealPale = Color(0xFFFBE9F1);
const _surface = Color(0xFFFFFFFF);
const _cardBg = Color(0xFFFFFAFC);
const _textPrimary = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF6B5B64);
const _divider = Color(0xFFF3D5E2);

class AttendanceDetailsDayCareView
    extends GetView<AttendanceDetailsDayCareController> {
  const AttendanceDetailsDayCareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _teal,
        centerTitle: true,
        title: const Text(
          'Monthly Daycare Attendance Student-wise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchAllDaycareAttendance();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterCard(),
                SizedBox(height: 16.h),
                _buildAttendanceTableCard(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _teal),
          SizedBox(width: 6.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _teal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Search Attendance', Icons.search_rounded),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStudentDropdown()),
              SizedBox(width: 12.w),
              Expanded(child: _buildMonthDropdown()),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAE275F), Color(0xFF97144D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: controller.isAttendanceLoading.value
                    ? null
                    : controller.onSearchTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: controller.isAttendanceLoading.value
                    ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.search, color: Colors.white, size: 20),
                label: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.5.sp, color: _textSecondary),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: _tealLight) : null,
      filled: true,
      fillColor: _cardBg,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _teal, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
        ),
      ),
    );
  }

  Widget _buildStudentDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Student Name *'),
          DropdownButtonFormField<DayCareStudent>(
            value: controller.selectedStudent.value,
            isExpanded: true,
            style: TextStyle(fontSize: 13.5.sp, color: _textPrimary),
            decoration:
            _fieldDeco('Select Student', icon: Icons.person_outline),
            items: controller.studentList.map((student) {
              return DropdownMenuItem<DayCareStudent>(
                value: student,
                child: Text(
                  student.studentName,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: controller.isStudentLoading.value
                ? null
                : (value) {
              controller.setSelectedStudent(value);
            },
          ),
        ],
      );
    });
  }

  Widget _buildMonthDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Month *'),
          DropdownButtonFormField<String>(
            value: controller.selectedMonth.value?['name']?.toString(),
            isExpanded: true,
            style: TextStyle(fontSize: 13.5.sp, color: _textPrimary),
            decoration:
            _fieldDeco('Select Month', icon: Icons.calendar_month_outlined),
            items: controller.monthList.map((month) {
              return DropdownMenuItem<String>(
                value: month['name'].toString(),
                child: Text(month['name'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.setSelectedMonth(value);
              }
            },
          ),
        ],
      );
    });
  }

  Widget _buildAttendanceTableCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: controller.isAttendanceLoading.value
          ? Padding(
        padding: EdgeInsets.all(40.w),
        child: const Center(
          child: CircularProgressIndicator(color: _teal),
        ),
      )
          : controller.attendanceList.isEmpty
          ? Padding(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy_outlined,
                  size: 56, color: Colors.grey.shade300),
              SizedBox(height: 10.h),
              Text(
                'No attendance data found',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Theme(
                data: Theme.of(Get.context!).copyWith(
                  dividerColor: _divider,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(_teal),
                  dataRowColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.transparent,
                  ),
                  columnSpacing: 24.w,
                  horizontalMargin: 16.w,
                  dataRowMinHeight: 52.h,
                  dataRowMaxHeight: 56.h,
                  columns: [
                    _buildColumn('S.No'),
                    _buildColumn('Student Name'),
                    _buildColumn('Status'),
                    _buildColumn('From Time'),
                    _buildColumn('To Time'),
                    _buildColumn('Total Hour'),
                    _buildColumn('Date'),
                    _buildColumn('Action'),
                  ],
                  rows: List.generate(
                    controller.attendanceList.length,
                        (index) {
                      final item = controller.attendanceList[index];
                      return _buildRow(
                        index: index,
                        serial: '${index + 1}',
                        studentName: item.studentName,
                        status: item.status,
                        fromTime: item.fromTime,
                        toTime: item.toTime,
                        totalHour: item.totalHour,
                        date: item.date,
                        actionText: item.actionText,
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
                color: _tealPale,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Hours',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: _teal,
                        ),
                      ),
                    ),
                    SizedBox(width: 18.w),
                    Text(
                      controller.totalHoursText,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: _teal,
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

  DataColumn _buildColumn(String title) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('present') || s.contains('active'))
      return const Color(0xFF2E7D32);
    if (s.contains('absent') || s.contains('inactive'))
      return const Color(0xFFC62828);
    if (s.contains('leave') || s.contains('half'))
      return const Color(0xFFEF6C00);
    return _textSecondary;
  }

  DataRow _buildRow({
    required int index,
    required String serial,
    required String studentName,
    required String status,
    required String fromTime,
    required String toTime,
    required String totalHour,
    required String date,
    required String actionText,
  }) {
    final textStyle = TextStyle(fontSize: 13.sp, color: _textPrimary);
    return DataRow(
      color: WidgetStateProperty.all(
        index.isEven ? _cardBg : Colors.white,
      ),
      cells: [
        DataCell(Text(serial, style: textStyle)),
        DataCell(Text(studentName,
            style: textStyle.copyWith(fontWeight: FontWeight.w600))),
        DataCell(_pill(status, _statusColor(status))),
        DataCell(Text(fromTime, style: textStyle)),
        DataCell(Text(toTime, style: textStyle)),
        DataCell(Text(totalHour, style: textStyle)),
        DataCell(Text(date, style: textStyle)),
        DataCell(_pill(
          actionText,
          actionText == 'Active'
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        )),
      ],
    );
  }
}