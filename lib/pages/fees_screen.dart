import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/session_model.dart' as session_model;

import '../controller/fees_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

// ─── Axis Bank maroon accent ───────────────────────────────────────────────
const Color kAxisMaroon = Color(0xFF97144D);

class FeesScreen extends GetView<FeesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Fees Management",
          style: TextStyle(
              fontSize: 22.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAxisMaroon, // Darker teal for the app bar
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Session & Class selection row
            Row(
              children: [
                Expanded(child: _buildSessionDropdown()),
                SizedBox(width: 12.w),
                Expanded(child: _buildClassDropdown()),
              ],
            ),
            SizedBox(height: 16.h),

            // Section selection row with Submit button
            Row(
              children: [
                Expanded(child: _buildSectionDropdown()),
                SizedBox(width: 12.w),
                _buildSubmitButton(),
              ],
            ),
            SizedBox(height: 20.h),

            // Student List Section
            Expanded(
              child: Obx(() {
                if (controller.isloading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.students.isEmpty) {
                  return Center(
                      child: Text('No students found',
                          style: TextStyle(fontSize: 18.sp)));
                }

                return ListView.builder(
                  itemCount: controller.students.length,
                  itemBuilder: (context, index) {
                    final student = controller.students[index];
                    return _buildStudentCard(student);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<session_model.sListDdata>(
        value: controller.selectedSession.value,
        hint: const Text("Select Session"),
        isExpanded: true,
        onChanged: (newVal) {
          controller.selectedSession.value = newVal;
          controller.session.value = newVal?.session ?? '';
        },
        items: controller.sessionList.map((session) {
          return DropdownMenuItem(
            value: session,
            child: Text(session.session ?? 'No session'),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Session',
          labelStyle: TextStyle(color: kAxisMaroon),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
      );
    });
  }

  Widget _buildClassDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<ListDataa>(
        value: controller.selectedClass.value,
        hint: const Text("Select Class"),
        isExpanded: true,
        onChanged: (val) {
          controller.setSelectedClass(val);
        },
        items: controller.listDataa.map((item) {
          return DropdownMenuItem<ListDataa>(
            value: item,
            child: Text(item.className ?? ""),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Class',
          labelStyle: TextStyle(color: kAxisMaroon),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
      );
    });
  }

  Widget _buildSectionDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<ListDatta>(
        value: controller.selectedSection.value,
        hint: const Text("Select Section"),
        isExpanded: true,
        onChanged: (newValue) {
          controller.selectedSection.value = newValue;
          controller.section = newValue?.sectionId ?? 0;
        },
        items: controller.sectionList.map((section) {
          return DropdownMenuItem<ListDatta>(
            value: section,
            child: Text(section.section ?? "No section"),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: "Section",
          labelStyle: TextStyle(color: kAxisMaroon),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () async {
          await controller.fetchStudents();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          'Submit',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStudentCard(student) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          student.studentName ?? 'No Name',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6.h),
            Text('Father: ${student.fatherName ?? '-'}',
                style: TextStyle(fontSize: 16.sp)),
            Text('Class: ${student.className ?? '-'}'),
            Text('Section: ${student.sectionName ?? '-'}'),
            Text('Father Phone: ${student.fatherPhone ?? '-'}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            String registrationNo = student.registrationNo ?? '';
            if (registrationNo.isEmpty) {
              Get.snackbar("Error", "Registration number missing");
              return;
            }

            final studentId = student.studentID ?? 0;
            final pickupPoint = student.pickupPoint ?? '';

            if (studentId == 0) {
              Get.snackbar("Error", "Student ID missing");
              return;
            }

            await controller.fetchStudentFeeData(
              studentId: studentId,
              pickupPoint: pickupPoint,
              registrationNo: registrationNo,
            );
            controller.filterAndNavigate(
              controller.studentfee.value,
              registrationNo,
              studentId,
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            backgroundColor: kAxisMaroon,
          ),
          child: Text(
            'FeePay',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}