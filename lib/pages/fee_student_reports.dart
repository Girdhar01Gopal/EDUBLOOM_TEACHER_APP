import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/session_model.dart' as session_model;
import 'package:teacher_app_edubloom/pages/student_wise_fee_screen.dart';
import '../binding/student_wise_fee_binding.dart';
import '../controller/fee_student_controller_reports.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);

class FeeStudentReportsScreen extends GetView<FeeStudentReportsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Fee Student Report",
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: kAxisMaroon,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row for session and class selection
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return DropdownButtonFormField<session_model.sListDdata>(
                      value: controller.selectedSession.value,
                      hint: const Text("Select Session"),
                      isExpanded: true,
                      selectedItemBuilder: (context) {
                        return controller.sessionList.map((session) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              session.session ?? "No session",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                      onChanged: (newVal) {
                        controller.selectedSession.value = newVal;
                        controller.session.value = newVal?.session ?? '';
                      },
                      items: controller.sessionList.map((session) {
                        return DropdownMenuItem(
                          value: session,
                          child: Text(
                            session.session ?? 'No session',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Session',
                        labelStyle: TextStyle(color: kAxisMaroon),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    );
                  }),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return DropdownButtonFormField<ListDataa>(
                      value: controller.selectedClass.value,
                      hint: const Text("Select Class"),
                      isExpanded: true,
                      items: controller.listDataa.map((item) {
                        return DropdownMenuItem<ListDataa>(
                          value: item,
                          child: Text(item.className ?? ""),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.setSelectedClass(val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        labelStyle: TextStyle(color: kAxisMaroon),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Row for section selection and submit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return DropdownButtonFormField<ListDatta>(
                      value: controller.selectedSection.value,
                      hint: const Text("Select Section"),
                      isExpanded: true,
                      items: controller.sectionList.map((section) {
                        return DropdownMenuItem<ListDatta>(
                          value: section,
                          child: Text(section.section ?? "No section"),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        controller.selectedSection.value = newValue;
                        controller.section = newValue?.sectionId ?? 0;
                      },
                      decoration: const InputDecoration(
                        labelText: "Section",
                        labelStyle: TextStyle(color: kAxisMaroon),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    );
                  }),
                ),
                SizedBox(width: 10.w),
                Container(
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
                      controller.fetchStudentData();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 20,
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      '🔎 Search',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // DataTable with FeeDetails Action column
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                      MaterialStateProperty.all(Colors.green),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text("S.No")),
                        DataColumn(label: Text("Registration No")),
                        DataColumn(label: Text("Student Name")),
                        DataColumn(label: Text("Father Name")),
                        DataColumn(label: Text("Total Fee Amount")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: [
                        ...controller.studentList.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                (controller.studentList.indexOf(student) + 1)
                                    .toString(),
                              )),
                              DataCell(Text(student.registrationNo ?? "-")),
                              DataCell(Text(student.studentName ?? "-")),
                              DataCell(Text(student.fatherName ?? "-")),
                              DataCell(Text('₹${student.totalFeeAmount}')),

                              // ✅ FeeDetails Button — session bhi pass ho raha hai
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(
                                          () => StudentWiseFeeScreen(),
                                      binding: StudentWiseFeeBinding(),
                                      arguments: {
                                        'registrationNo': student.registrationNo ?? '',
                                        'studentName': student.studentName ?? '',
                                        'session': controller.selectedSession.value?.session ?? '',
                                        'studentId': student.studentId ?? 0,  // ← ADD THIS
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'FeeDetails',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}