import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/session_model.dart' as session_model;
import '../controller/stationary_fee_student_controller.dart';
import '../infrastructures/routes/page_constants.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

class StationaryFeeStudentScreen extends GetView<StationaryFeeStudentController> {
  const StationaryFeeStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              title: Text(
                "Stationary Fee Student",
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.teal.shade800,
              elevation: 2,
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "Add"),
                  Tab(text: "View"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildAddTab(context),
                _buildViewTab(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddTab(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stationary Fee Student",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20.h),

                /// Class
                Text(
                  "Class *",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<ListDataa>(
                  value: controller.selectedClass.value,
                  isExpanded: true,
                  hint: const Text("Select Class"),
                  items: controller.listDataa.map((item) {
                    return DropdownMenuItem<ListDataa>(
                      value: item,
                      child: Text(item.className ?? ""),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.setSelectedClass(val);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                /// Section
                Text(
                  "Section *",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<ListDatta>(
                  value: controller.selectedSection.value,
                  isExpanded: true,
                  hint: const Text("Select Section"),
                  items: controller.sectionList.map((section) {
                    return DropdownMenuItem<ListDatta>(
                      value: section,
                      child: Text(section.section ?? "No section"),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    controller.setSelectedSection(newValue);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                /// Session
                Text(
                  "Session *",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<session_model.sListDdata>(
                  value: controller.selectedSession.value,
                  isExpanded: true,
                  hint: const Text("Select Session"),
                  items: controller.sessionList.map((session) {
                    return DropdownMenuItem<session_model.sListDdata>(
                      value: session,
                      child: Text(session.session ?? "No session"),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    controller.setSelectedSession(newVal);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.fetchStudentData();
                      if (controller.studentList.isNotEmpty) {
                        DefaultTabController.of(context).animateTo(1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildViewTab() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stationary Fee Student List",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                const Divider(),
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.studentList.isEmpty
                      ? const Center(
                    child: Text("No data available"),
                  )
                      : Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey.shade200,
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
                          rows: List.generate(
                            controller.studentList.length,
                                (index) {
                              final student =
                              controller.studentList[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text("${index + 1}")),
                                  DataCell(Text(
                                      student.registrationNo ?? "-")),
                                  DataCell(Text(
                                      student.studentName ?? "-")),
                                  DataCell(Text(
                                      student.fatherName ?? "-")),
                                  DataCell(
                                      Text(student.className ?? "-")),
                                  DataCell(Text(
                                      student.sectionName ?? "-")),
                                  DataCell(Text(
                                      student.fatherPhone ?? "-")),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.toNamed(
                                          RouteName.stationaryfeeaction,
                                          arguments: {
                                            'studentId':
                                            student.studentID,
                                            'schoolId':
                                            controller.schoolId,
                                            'currentSession': controller
                                                .selectedSession
                                                .value
                                                ?.session ??
                                                '',
                                            'registrationNo':
                                            student.registrationNo,
                                            'studentName':
                                            student.studentName,
                                            'className':
                                            student.className,
                                            'sectionName':
                                            student.sectionName,
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Colors.teal.shade700,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                      ),
                                      child: const Text(
                                        "stationary fee",
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

const TextStyle _headerStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 15,
);