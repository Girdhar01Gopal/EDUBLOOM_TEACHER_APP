import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/FeedetailsStudentReportsController.dart';

class Feedetailsstudentreportsscreen extends GetView<Feedetailsstudentreportscontroller> {
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
        title: Text("Fee Student Report", style: TextStyle(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row for session selection and registration number input
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isSessionLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return DropdownButtonFormField<String>(
                      value: controller.selectedSession.value,
                      hint: const Text("Select Session"),
                      isExpanded: true,
                      onChanged: (newVal) {
                        controller.selectedSession.value = newVal ?? '';
                      },
                      items: controller.sessionList.map((session) {
                        return DropdownMenuItem<String>(
                          value: session,
                          child: Text(session),
                        );
                      }).toList(),
                      decoration: InputDecoration(
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
              ],
            ),
            SizedBox(height: 20.h),

            // Registration number input
            TextFormField(
              controller: controller.registrationNoController,
              decoration: InputDecoration(
                labelText: "🔎 Search (Registration No)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.h),

            // Submit button
            ElevatedButton(
              onPressed: controller.fetchFeeData,
              child: Text("🔎 Search", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20), backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20.h),

            // Displaying Paid and Unpaid Fee sections
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: [
                    // Paid Fee Section
                    if (controller.paidFeeList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Paid Fee", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            DataTable(
                              columns: [
                                DataColumn(label: Text("S.No")),
                                DataColumn(label: Text("Pay Date")),
                                DataColumn(label: Text("Amount")),
                              ],
                              rows: controller.paidFeeList.map((fee) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(fee.sNo)),
                                    DataCell(Text(fee.payDate)),
                                    DataCell(Text(fee.amount)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Unpaid Fee Section
                    if (controller.unpaidFeeList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Unpaid Fee", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            DataTable(
                              columns: [
                                DataColumn(label: Text("S.No")),
                                DataColumn(label: Text("Fee Type")),
                                DataColumn(label: Text("Amount")),
                              ],
                              rows: controller.unpaidFeeList.map((fee) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(fee.sNo)),
                                    DataCell(Text(fee.feeType)),
                                    DataCell(Text(fee.amount)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Display total unpaid amount
                    if (controller.unpaidFeeList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Total Unpaid Amount: ₹${controller.totalUnpaidAmount}",
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
