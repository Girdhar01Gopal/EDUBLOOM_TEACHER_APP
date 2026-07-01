import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;

import '../controller/discount_list_master.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);

class DiscountListMasterScreen extends StatelessWidget {
  DiscountListMasterScreen({super.key});

  final DiscountListMasterController controller =
  Get.put(DiscountListMasterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAxisMaroon,
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Fee Discount List",
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
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
                        return DropdownMenuItem<session_model.sListDdata>(
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
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                      controller.fetchDiscountData();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 20,
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
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

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.discountList.isEmpty) {
                  return const Center(
                    child: Text(
                      "No discount data found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
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
                        //DataColumn(label: Text("Registration No")),
                        DataColumn(label: Text("Student Name")),
                        DataColumn(label: Text("Father Name")),
                        DataColumn(label: Text("Class Name")),
                        DataColumn(label: Text("Section Name")),
                        DataColumn(label: Text("Fee Type")),
                        DataColumn(label: Text("Fee Duration")),
                        DataColumn(label: Text("Discount")),
                      ],
                      rows: List.generate(
                        controller.discountList.length,
                            (index) {
                          final item = controller.discountList[index];
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              // DataCell(Text(item.registrationNo ?? '-')),
                              DataCell(Text(item.studentName ?? '-')),
                              DataCell(Text(item.fatherName ?? '-')),
                              DataCell(Text(item.className ?? '-')),
                              DataCell(Text(item.sectionName ?? '-')),
                              DataCell(Text(item.feeTypeName ?? '-')),
                              DataCell(Text(item.feeDurationName ?? '-')),
                              DataCell(
                                Text(
                                  item.discount != null
                                      ? item.discount!.toStringAsFixed(0)
                                      : '0',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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