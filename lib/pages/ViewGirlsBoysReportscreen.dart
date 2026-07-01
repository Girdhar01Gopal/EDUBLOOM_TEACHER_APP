import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/ViewGirlsBoysReportcontroller.dart';
import '../models/session_model.dart' as session_model;

class ViewGirlsBoysReportScreen extends GetView<ViewGirlsBoysReportController> {
  const ViewGirlsBoysReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Text(
          "View Girls Boys Report",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: teal,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // loaders
              Obx(() => controller.isPageLoading.value
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink()),
              SizedBox(height: 10.h),

              // Row for session and gender selection
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return DropdownButtonFormField<session_model.sListDdata>(
                        value: controller.selectedSession.value,
                        hint: const Text("Select Session"),
                        isExpanded: true,
                        items: controller.sessionList.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.session ?? 'No session',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: controller.setSelectedSession,
                        decoration: InputDecoration(
                          labelText: 'Session',
                          labelStyle: const TextStyle(color: Color(0xFF97144D)),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 10.w),

                  // ✅ Gender Dropdown UPDATED: Boy/Girl/Other + required star
                  Expanded(
                    child: Obx(() {
                      return DropdownButtonFormField<String>(
                        value: controller.selectedGender.value.isEmpty
                            ? null
                            : controller.selectedGender.value,
                        hint: const Text("Select Gender"),
                        isExpanded: true,
                        items: controller.genderList.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(
                              g,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                        controller.selectedGender.value = val ?? '',
                        decoration: InputDecoration(
                          label: RichText(
                            text: const TextSpan(
                              text: "Gender",
                              style: TextStyle(color: Color(0xFF97144D)),
                              children: [
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) => val == null ? 'Required' : null,
                      );
                    }),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Submit button with gradient
              Obx(() {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade300, Colors.pink.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async => controller.fetchStudents(),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.w, vertical: 16.h),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 16.h),

              // Total Students
              Obx(() {
                final total = controller.reportList.length;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Total Students : $total *",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                );
              }),

              SizedBox(height: 10.h),

              // Data table with horizontal and vertical scrolling
              Obx(() {
                if (controller.isSubmitting.value) {
                  return const SizedBox.shrink();
                }

                if (controller.reportList.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: const Text("No data found."),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Vertical scrolling
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                    child: DataTable(
                      headingRowColor:
                      MaterialStateProperty.all(Colors.green),
                      columns: const [
                        DataColumn(
                            label:
                            Text("S.No", style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Registration No",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Academic Year",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Student Name",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Father's Name",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label:
                            Text("Class", style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Section",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Father's Mobile No.",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("Gender",
                                style: TextStyle(color: Colors.white))),
                      ],
                      rows: List.generate(controller.reportList.length, (i) {
                        final x = controller.reportList[i];
                        return DataRow(
                          cells: [
                            DataCell(Text("${i + 1}")),
                            DataCell(Text(x.registrationNo ?? "")),
                            DataCell(Text(x.session ?? "")),
                            DataCell(Text(x.studentName ?? "")),
                            DataCell(Text(x.fatherName ?? "")),
                            DataCell(Text(x.className ?? "")),
                            DataCell(Text(x.section ?? "")),
                            DataCell(Text(x.fMobileno ?? "")),
                            DataCell(Text(x.sex ?? "")),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}