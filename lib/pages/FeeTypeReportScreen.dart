import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model; // ✅ fixed: relative import

import '../controller/FeeTypeReportController.dart';
import '../models/classmodel.dart';
import '../models/fee_type_model.dart';

class FeeTypeReportScreen extends GetView<FeeTypeReportController> {
  const FeeTypeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = Colors.teal.shade800;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Text(
          "Fee Type Report",
          style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.w800),
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
              Obx(() {
                if (controller.isPageLoading.value) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              }),

              SizedBox(height: 10.h),

              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return DropdownButtonFormField<session_model.sListDdata>(
                        value: controller.selectedSession.value,
                        isExpanded: true,
                        hint: const Text("Select Session"),
                        items: controller.sessionList
                            .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.session ?? ''), // ✅ null-safe
                        ))
                            .toList(),
                        onChanged: controller.setSelectedSession,
                        decoration: const InputDecoration(
                          labelText: 'Session',
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
                      return DropdownButtonFormField<fData>(
                        value: controller.selectedFeeType.value,
                        isExpanded: true,
                        hint: const Text("Select Fee Type"),
                        items: controller.feeTypeList
                            .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.feeType ?? ''),
                        ))
                            .toList(),
                        onChanged: controller.setSelectedFeeType,
                        decoration: const InputDecoration(
                          labelText: 'Fee Type',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      );
                    }),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              Obx(() {
                return DropdownButtonFormField<ListDataa>(
                  value: controller.selectedClass.value,
                  isExpanded: true,
                  hint: const Text("Select Class"),
                  items: controller.listDataa
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.className ?? ''),
                  ))
                      .toList(),
                  onChanged: controller.setSelectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                );
              }),

              SizedBox(height: 16.h),

              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.isSearching.value ? null : controller.searchReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade500,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.isSearching.value
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      "🔎Search",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                );
              }),

              SizedBox(height: 16.h),

              Obx(() {
                if (controller.isSearching.value) return const SizedBox.shrink();

                if (controller.feeReportList.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: const Text("No data available."),
                  );
                }

                return Column(
                  children: controller.feeReportList.map((x) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${x.studentName} (${x.registrationNo})",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Expanded(child: Text("FeeType: ${x.feeType}", style: TextStyle(fontSize: 12.sp))),
                              Expanded(child: Text("Month: ${x.feeMonth}", style: TextStyle(fontSize: 12.sp))),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Expanded(child: Text("Pay: ${x.payAmount}", style: TextStyle(fontSize: 12.sp, color: Colors.green))),
                              Expanded(child: Text("Due: ${x.dueAmount}", style: TextStyle(fontSize: 12.sp))),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Payment: ${x.payment ?? 'N/A'}",
                            style: TextStyle(fontSize: 12.sp, color: Colors.green),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Date: ${_formatDate(x.payDate ?? '')}",
                            style: TextStyle(fontSize: 12.sp, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isNotEmpty) {
      DateTime parsedDate = DateTime.parse(date);
      return "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
    }
    return "-";
  }
}