import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teacher_app_edubloom/models/session_model.dart' as session_model;
import 'package:teacher_app_edubloom/models/transfer_certificate1_model.dart'
as tc_model;

import '../controller/TransferCertificateReportsController.dart';
import '../infrastructures/routes/page_constants.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import 'TcCertificateDownloadScreen.dart';

class TransferCertificateReportsScreen
    extends GetView<TransferCertificateReportsController> {
  const TransferCertificateReportsScreen({Key? key}) : super(key: key);

  void _showSearchSheet(BuildContext context) {
    final TextEditingController searchCtrl = TextEditingController(
      text: controller.searchQuery.value,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search, color: Colors.teal.shade800),
                  SizedBox(width: 8.w),
                  Text(
                    "Search Student",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                  "Search by Name, Reg. No, Father or Mother Name…",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchCtrl.clear();
                      controller.searchQuery.value = '';
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.teal.shade800, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (val) => controller.searchQuery.value = val,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        searchCtrl.clear();
                        controller.searchQuery.value = '';
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.teal.shade800),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(color: Colors.teal.shade800),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "📚 Transfer Certificate",
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 26),
            tooltip: "Search Student",
            onPressed: () => _showSearchSheet(context),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return DropdownButtonFormField<session_model.sListDdata>(
                      value: controller.selectedSession.value,
                      hint: const Text("Select Session"),
                      isExpanded: true,
                      selectedItemBuilder: (context) {
                        return controller.sessionList.map((s) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              s.session ?? "No session",
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
                      items: controller.sessionList.map((s) {
                        return DropdownMenuItem<session_model.sListDdata>(
                          value: s,
                          child: Text(
                            s.session ?? 'No session',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Session',
                        labelStyle: TextStyle(color: Colors.teal),
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
                      onChanged: (val) => controller.setSelectedClass(val),
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        labelStyle: TextStyle(color: Colors.teal),
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

            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return DropdownButtonFormField<ListDatta>(
                      value: controller.selectedSection.value,
                      hint: const Text("Select Section"),
                      isExpanded: true,
                      items: controller.sectionList.map((sec) {
                        return DropdownMenuItem<ListDatta>(
                          value: sec,
                          child: Text(sec.section ?? "No section"),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        controller.selectedSection.value = newValue;
                        controller.section = newValue?.sectionId ?? 0;
                      },
                      decoration: const InputDecoration(
                        labelText: "Section",
                        labelStyle: TextStyle(color: Colors.teal),
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
                    onPressed: () => controller.fetchStudentData(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Search',
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

            Obx(() {
              final q = controller.searchQuery.value.trim();
              if (q.isEmpty) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('🔍 "$q"'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => controller.searchQuery.value = '',
                  backgroundColor: Colors.teal.shade50,
                  side: BorderSide(color: Colors.teal.shade800),
                ),
              );
            }),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.studentList.isEmpty) {
                  return const Center(
                    child: Text(
                      "No data found.\nPlease select filters and press Search.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final List<tc_model.TCStudentData> filtered =
                    controller.filteredStudentList;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 12.h),
                        Text(
                          'No student matches "${controller.searchQuery.value}"',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          Colors.teal.shade800),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      columns: const [
                        DataColumn(label: Text("S.No")),
                        DataColumn(label: Text("Registration No")),
                        DataColumn(label: Text("Student Name")),
                        DataColumn(label: Text("Father Name")),
                        DataColumn(label: Text("Class")),
                        DataColumn(label: Text("Section")),
                        DataColumn(label: Text("Father Phone")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: List<DataRow>.generate(filtered.length, (index) {
                        final tc_model.TCStudentData student = filtered[index];

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => index % 2 == 0
                                ? Colors.white
                                : Colors.teal.shade50,
                          ),
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(student.registrationNo ?? "-")),
                            DataCell(Text(student.studentName ?? "-")),
                            DataCell(Text(student.fatherName ?? "-")),
                            DataCell(Text(student.className ?? "-")),
                            DataCell(Text(student.sectionName ?? "-")),
                            DataCell(Text(student.fatherPhone ?? "-")),

                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: "Save TC",
                                    child: InkWell(
                                      onTap: () {
                                        Get.toNamed(
                                          RouteName.tccertificatedownload,
                                          arguments: {
                                            'studentId': student.studentID,
                                            'schoolId': controller.schoolId,
                                            'currentSession':
                                            student.session ??
                                                controller.session.value,
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        margin:
                                        const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade600,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.workspace_premium,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Download TC",
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(
                                              () => TcCertificateDownloadScreen(
                                            studentId:
                                            student.studentID ?? 0,
                                            schoolId: controller.schoolId,
                                            session: student.session ??
                                                controller.session.value,
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade600,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.download,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
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