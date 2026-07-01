import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;


import '../controller/report_card_controller.dart';
import '../controller/reportcarddetailcontroller.dart';
import '../models/classmodel.dart';
import '../models/terms_result_model.dart';
import 'ReportCardDetailScreenfull.dart';

const Color axisMaroon = Color(0xFF97144D);
const Color axisMaroonLight = Color(0xFFF3E0E9);

class ReportCardScreen extends GetView<ReportCardController> {
  const ReportCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Report Card",
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6E0F38),
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Card ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _classDropdown()),
                        SizedBox(width: 12.w),
                        Expanded(child: _sessionDropdown()),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(child: _sectionDropdown()),
                        SizedBox(width: 12.w),
                        Expanded(child: _termDropdown()),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSearching.value
                            ? null
                            : controller.searchReportCards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isSearching.value
                              ? Colors.grey
                              : Colors.pink.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        icon: controller.isSearching.value
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                            : const Icon(Icons.search,
                            color: Colors.white, size: 20),
                        label: Text(
                          controller.isSearching.value
                              ? "Searching..."
                              : "Search",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
                  ],
                );
              }),
            ),
            SizedBox(height: 20.h),

            // ── Results ──
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.uniqueStudentList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined,
                            size: 56, color: Colors.grey.shade300),
                        SizedBox(height: 14.h),
                        Text(
                          "No data found.\nSelect filters and press Search.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.uniqueStudentList.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = controller.uniqueStudentList[index];
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Serial badge
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: axisMaroonLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: axisMaroon,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Student info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.studentName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  item.registrationNo,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Row(
                                  children: [
                                    _chip(item.className,
                                        axisMaroonLight,
                                        axisMaroon),
                                    SizedBox(width: 6.w),
                                    _chip(item.term,
                                        Colors.pink.shade50,
                                        Colors.pink.shade700),
                                    SizedBox(width: 6.w),
                                    _chip(item.section,
                                        Colors.orange.shade50,
                                        Colors.orange.shade700),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // ── Print Button ──
                          ElevatedButton.icon(
                            onPressed: () {
                              // Purana controller delete karo
                              if (Get.isRegistered<ReportCardDetailController>()) {
                                Get.delete<ReportCardDetailController>(
                                    force: true);
                              }

                              // Naya controller banao
                              final ctrl =
                              Get.put(ReportCardDetailController());

                              // Values set karo PEHLE navigate karne se
                              ctrl.studentId = item.studentId;
                              ctrl.classId   = item.classId;
                              ctrl.session   = controller.session.value;
                              ctrl.term      = item.term;

                              debugPrint(
                                  "Navigating => studentId:${item.studentId} "
                                      "classId:${item.classId} "
                                      "session:${controller.session.value} "
                                      "term:${item.term}");

                              // Navigate karo
                              Get.to(
                                    () => const ReportCardDetailScreen(),
                                transition: Transition.rightToLeft,
                                duration:
                                const Duration(milliseconds: 300),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.print,
                                color: Colors.white, size: 16),
                            label: Text(
                              "Print",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _classDropdown() {
    return Obx(() => DropdownButtonFormField<ListDataa>(
      value: controller.selectedClass.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: const Text("Select Class",
          style: TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis),
      decoration: _dec("Class"),
      items: controller.listDataa
          .map((c) => DropdownMenuItem<ListDataa>(
        value: c,
        child: Text(c.className ?? "",
            overflow: TextOverflow.ellipsis),
      ))
          .toList(),
      onChanged: (v) => controller.setSelectedClass(v),
    ));
  }

  Widget _sessionDropdown() {
    return Obx(() => DropdownButtonFormField<session_model.sListDdata>(
      value: controller.selectedSession.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: const Text("Select Session",
          style: TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis),
      decoration: _dec("Session"),
      items: controller.sessionList
          .map((s) => DropdownMenuItem<session_model.sListDdata>(
        value: s,
        child: Text(s.session ?? "",
            overflow: TextOverflow.ellipsis),
      ))
          .toList(),
      onChanged: (v) {
        controller.selectedSession.value = v;
        controller.session.value = v?.session ?? '';
      },
    ));
  }

  Widget _sectionDropdown() {
    return Obx(() => DropdownButtonFormField<dynamic>(
      value: controller.selectedSection.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: const Text("Select Section",
          style: TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis),
      decoration: _dec("Section"),
      items: controller.sectionList
          .map((s) => DropdownMenuItem<dynamic>(
        value: s,
        child: Text((s.section ?? "").toString(),
            overflow: TextOverflow.ellipsis),
      ))
          .toList(),
      onChanged: (v) => controller.selectedSection.value = v,
    ));
  }

  Widget _termDropdown() {
    return Obx(() => DropdownButtonFormField<TermData>(
      value: controller.selectedTerm.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: const Text("Select Term",
          style: TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis),
      decoration: _dec("Term"),
      items: controller.termList
          .map((t) => DropdownMenuItem<TermData>(
        value: t,
        child: Text(t.term ?? "",
            overflow: TextOverflow.ellipsis),
      ))
          .toList(),
      onChanged: (v) => controller.selectedTerm.value = v,
    ));
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: "$label *",
    labelStyle: TextStyle(
        color: axisMaroon, fontWeight: FontWeight.w600),
    border:
    OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: axisMaroon)),
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}