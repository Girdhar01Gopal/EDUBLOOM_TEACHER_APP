import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/daycareattendancecontroller2.dart';

class AttendanceDetailsDayCareView extends GetView<AttendanceDetailsDayCareController> {
  const AttendanceDetailsDayCareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF97144D),
        centerTitle: true,
        title: const Text(
          'Attendance Details Day Care',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildFilterCard(),
              SizedBox(height: 14.h),
              _buildAttendanceTableCard(),
            ],
          ),
        );
      }),
    );
  }



  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStudentDropdown()),
              SizedBox(width: 14.w),
              Expanded(child: _buildMonthDropdown()),
            ],
          ),
          SizedBox(height: 18.h),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 42.h,
              child: ElevatedButton(
                onPressed: controller.isAttendanceLoading.value
                    ? null
                    : controller.onSearchTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                ),
                child: controller.isAttendanceLoading.value
                    ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Name*',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<DayCareStudent>(
            value: controller.selectedStudent.value,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Select Student Name',
              hintStyle: TextStyle(fontSize: 14.sp),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Color(0xFFD9DDE3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Color(0xFFD9DDE3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Color(0xFF97144D)),
              ),
            ),
            items: controller.studentList.map((student) {
              return DropdownMenuItem<DayCareStudent>(
                value: student,
                child: Text(
                  student.studentName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp),
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
          Text(
            'Month *',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: controller.selectedMonth.value?['name']?.toString(),
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Please Select Month',
              hintStyle: TextStyle(fontSize: 14.sp),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Color(0xFFD9DDE3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Color(0xFFD9DDE3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Color(0xFF97144D)),
              ),
            ),
            items: controller.monthList.map((month) {
              return DropdownMenuItem<String>(
                value: month['name'].toString(),
                child: Text(
                  month['name'].toString(),
                  style: TextStyle(fontSize: 14.sp),
                ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: controller.isAttendanceLoading.value
          ? Padding(
        padding: EdgeInsets.all(30.w),
        child: const Center(child: CircularProgressIndicator()),
      )
          : controller.attendanceList.isEmpty
          ? Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Text(
            'No attendance data found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF212529)),
              columnSpacing: 28.w,
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
            Container(
              width: 1030.w,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              color: const Color(0xFFD7E8FF),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total Hours',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    flex: 2,
                    child: Text(
                      controller.totalHoursText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
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

  DataColumn _buildColumn(String title) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  DataRow _buildRow({
    required String serial,
    required String studentName,
    required String status,
    required String fromTime,
    required String toTime,
    required String totalHour,
    required String date,
    required String actionText,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(serial)),
        DataCell(Text(studentName)),
        DataCell(Text(status)),
        DataCell(Text(fromTime)),
        DataCell(Text(toTime)),
        DataCell(Text(totalHour)),
        DataCell(Text(date)),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: actionText == 'Active' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}