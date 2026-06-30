import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;

import '../controller/day_care_controller.dart';

class DayCare extends GetView<DayCareController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("👶 Day Care Management",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _buildSessionAndSubmitBar(),
            SizedBox(height: 20.h),
            Expanded(child: _studentList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionAndSubmitBar() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _sessionDropdown()),
          SizedBox(width: 12.w),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _sessionDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<session_model.sListDdata>(
        value: controller.selectedSession.value,
        hint: const Text("Select Session"),
        onChanged: (newVal) {
          if (newVal != null) {
            controller.setSelectedSession(newVal);
          }
        },
        items: controller.sessionList.map((session) {
          return DropdownMenuItem(
            value: session,
            child: Text(
              session.session ?? 'No session',
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Session',
          labelStyle: TextStyle(fontSize: 14.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade300, Colors.pink.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.search, color: Colors.white),
        label: Text(
          "Submit",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          if (controller.session.value.isEmpty) {
            Get.snackbar(
              'Warning',
              'Please select a session first',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
          controller.fetchDaycareStudents();
        },
      ),
    );
  }

  Widget _studentList() {
    return Obx(() {
      if (controller.isloading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading students...'),
            ],
          ),
        );
      }

      if (controller.studentList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'No students found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.studentList.length,
        itemBuilder: (context, index) {
          final student = controller.studentList[index];
          return _buildStudentCard(student);
        },
      );
    });
  }

  Widget _buildStudentCard(dynamic student) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.pink.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.pink.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              student.studentName ?? 'Unknown',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _buildInfoRow('Registration', student.registrationNo ?? 'N/A'),
                _buildInfoRow('Father', student.fatherName ?? 'N/A'),
                // _buildInfoRow('Class', student.className ?? 'N/A'),
                // _buildInfoRow('Section', student.sectionName ?? 'N/A'),
                _buildInfoRow('Phone', student.fatherPhone ?? 'N/A'),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _buildActionButton(student),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(dynamic student) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (student.registrationNo == null || student.registrationNo.toString().isEmpty) {
            Get.snackbar(
              'Error',
              'Registration number not found',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          controller.fetchDaycareFeeData(
            student.studentID,
            student.registrationNo,
          );
        },
        icon: const Icon(Icons.payment, size: 20),
        label: Text(
          'View Fee Details',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          elevation: 4,
        ),
      ),
    );
  }
}