import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/student_wise_fee_controller.dart';

class StudentWiseFeeScreen extends GetView<StudentWiseFeeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Student Wise Fee",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student info display
            Obx(() => Text(
              "studentName: ${controller.studentName.value}"
                  "${controller.studentClass.value.isNotEmpty ? ' /class: ${controller.studentClass.value}' : ''}",
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            )),
            SizedBox(height: 16.h),

            // Search by Registration No
            Text(
              "Search (Registration No)*",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.regNoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            SizedBox(height: 16.h),

            // Search Button — dono APIs call hogi
            ElevatedButton(
              onPressed: () {
                controller.onSearchPressed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ─── Content Area ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ════════════════════════════
                    // PAID FEE SECTION
                    // ════════════════════════════
                    Text(
                      "Paid Fee",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Obx(() {
                      if (controller.isPaidLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.paidFeeList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "No paid fee records found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                          MaterialStateProperty.all(const Color(0xFF97144D)),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          columns: const [
                            DataColumn(label: Text("S.No")),
                            DataColumn(label: Text("Pay Date")),
                            DataColumn(label: Text("Student Name")),
                            DataColumn(label: Text("Father Name")),
                            DataColumn(label: Text("Cls/Sec")),
                            DataColumn(label: Text("Fee Type")),
                            DataColumn(label: Text("Fee Month")),
                            DataColumn(label: Text("Pay Mode")),
                            DataColumn(label: Text("Pay Amount")),
                            DataColumn(label: Text("Due Amount")),
                          ],
                          rows: controller.paidFeeList
                              .asMap()
                              .entries
                              .map((entry) {
                            final i = entry.key;
                            final fee = entry.value;

                            // payDate format: "2026-04-03T00:00:00" → "03-04-2026"
                            String formattedDate = '-';
                            if (fee.payDate != null &&
                                fee.payDate!.isNotEmpty) {
                              try {
                                final dt = DateTime.parse(fee.payDate!);
                                formattedDate =
                                '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
                              } catch (_) {
                                formattedDate = fee.payDate ?? '-';
                              }
                            }

                            return DataRow(cells: [
                              DataCell(Text('${i + 1}')),
                              DataCell(Text(formattedDate)),
                              DataCell(Text(fee.studentName ?? '-')),
                              DataCell(Text(fee.fatherName ?? '-')),
                              DataCell(Text(
                                '${fee.studentClass ?? '-'} (${fee.section ?? '-'})',
                              )),
                              DataCell(Text(
                                  fee.feeTypeDisplay ?? fee.feetype ?? '-')),
                              DataCell(Text(fee.feeMonth ?? '-')),
                              DataCell(Text(fee.paymentMode ?? '-')),
                              DataCell(
                                  Text('₹${fee.payAmount?.toInt() ?? 0}')),
                              DataCell(
                                  Text('₹${fee.dueAmount?.toInt() ?? 0}')),
                            ]);
                          }).toList(),
                        ),
                      );
                    }),

                    SizedBox(height: 24.h),

                    // ════════════════════════════
                    // UNPAID FEE SECTION
                    // ════════════════════════════
                    Text(
                      "Unpaid Fee",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Obx(() {
                      if (controller.isUnpaidLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.unpaidFeeList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "No unpaid fee records found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                              Colors.orange.shade700),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          columns: const [
                            DataColumn(label: Text("S.No")),
                            DataColumn(label: Text("Student Name")),
                            DataColumn(label: Text("Father Name")),
                            DataColumn(label: Text("Class/Section")),
                            DataColumn(label: Text("Fee Type")),
                            DataColumn(label: Text("Fee Month")),
                            DataColumn(label: Text("Discount")),
                            DataColumn(label: Text("Fee Amount")),
                          ],
                          rows: controller.unpaidFeeList
                              .asMap()
                              .entries
                              .map((entry) {
                            final i = entry.key;
                            final fee = entry.value;
                            return DataRow(cells: [
                              DataCell(Text('${i + 1}')),
                              DataCell(Text(fee.studentName ?? '-')),
                              DataCell(Text(fee.fatherName ?? '-')),
                              DataCell(Text(
                                '${fee.studentClass ?? '-'} (${fee.section ?? '-'})',
                              )),
                              DataCell(Text(
                                  fee.feeTypeDisplay ?? fee.feetype ?? '-')),
                              DataCell(Text(fee.feeMonth ?? '-')),
                              DataCell(
                                  Text('${fee.discount?.toInt() ?? 0}')),
                              DataCell(Text(
                                  '₹${fee.netFeeAmount?.toInt() ?? 0}')),
                            ]);
                          }).toList(),
                        ),
                      );
                    }),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}