import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/all_fee_report_controller.dart';
import '../models/all_fee_report_model.dart';
import '../models/classmodel.dart';
import '../models/fee_type_model.dart';
import '../models/session_model.dart' as session_model;

class AllFeeReportScreen extends GetView<AllFeeReportController> {
  const AllFeeReportScreen({super.key});

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
          "All Fee Report",
          style: TextStyle(
            fontSize: 24.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: teal,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            Obx(() => controller.isPageLoading.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink()),
            SizedBox(height: 10.h),

            // Filter UI (Dropdowns + GO button)
            _filtersCard(teal),

            SizedBox(height: 20.h),

            // Display the Fee Report Data
            Expanded(
              child: Obx(() {
                return controller.rows.isEmpty
                    ? Center(child: Text('No data available'))
                    : ListView.builder(
                        itemCount: controller.rows.length,
                        itemBuilder: (context, index) {
                          final report = controller.rows[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Student Name
                                  Text(
                                    'Student Name: ${report.studentName ?? 'Not Available'}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Registration No: ${report.registrationNo ?? 'Not Available'}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),

                                  // Tuition and Transport Fee
                                  _buildFeeDetails(
                                    'Tuition Fee',
                                    report.tutionFee,
                                  ),
                                  _buildFeeDetails(
                                    'Transport Fee',
                                    report.transportFee,
                                  ),

                                  // Total Amount
                                  _buildFeeDetails(
                                    'Total Amount',
                                    report.totalAmount,
                                    isBold: true,
                                  ),

                                  // Payment Details (APR, AUG, SEP)
                                  _buildPaymentRow(report),

                                  SizedBox(height: 10.h),

                                  // Due Amounts (APR, OCT, DEC)
                                  _buildDueRow(report),
                                ],
                              ),
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

  // Helper Widget to display fee details
  Widget _buildFeeDetails(String label, int? amount, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        '$label: \₹${amount ?? 0}',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

// Helper Widget to display payment amounts (APR, AUG, SEP)
Widget _buildPaymentRow(AllFeesReport report) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildPaymentAmount('APR', report.apRPayAmount),
      _buildPaymentAmount('AUG', report.auGPayAmount),
      _buildPaymentAmount('SEP', report.sePPayAmount),
    ],
  );
}

// Helper Widget to display due amounts (APR, OCT, DEC)
Widget _buildDueRow(AllFeesReport report) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildDueAmount('APR', report.apRDueAmount),
      _buildDueAmount('OCT', report.ocTPayAmount),
      _buildDueAmount('DEC', report.deCPayAmount),
    ],
  );
}

// Helper Widget to display payment amount for a specific month
Widget _buildPaymentAmount(String month, int? amount) {
  return Column(
    children: [
      Text(
        '$month Payment:',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 4.h),
      Text(
        '\₹${amount ?? 0}',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

// Helper Widget to display due amount for a specific month
Widget _buildDueAmount(String month, int? amount) {
  return Column(
    children: [
      Text(
        '$month Due:',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 4.h),
      Text(
        '\₹${amount ?? 0}',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

  // Helper Widget to display payment amount for a specific month

  // Helper Widget to display due amount for a specific month

  // FILTER CARD (Dropdowns + GO button)
  Widget _filtersCard(Color teal) {
    InputDecoration _dec(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16.sp, // Larger label size
        color: Colors.black87,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: teal, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
    );

    final dropdownTextStyle = TextStyle(
      fontSize: 16.sp, // Larger dropdown value text
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Session + Fee Type
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<session_model.sListDdata>(
                    value: controller.selectedSession.value,
                    isExpanded: true,
                    style: dropdownTextStyle,
                    items: controller.sessionList
                        .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.session ?? '', style: dropdownTextStyle),
                    ))
                        .toList(),
                    onChanged: controller.setSelectedSession,
                    decoration: _dec("Session *"),
                  );
                }),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<fData>(
                    value: controller.selectedFeeType.value,
                    isExpanded: true,
                    style: dropdownTextStyle,
                    items: controller.feeTypeList
                        .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.feeType ?? '', style: dropdownTextStyle),
                    ))
                        .toList(),
                    onChanged: controller.setSelectedFeeType,
                    decoration: _dec("Fee Type *"),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Row 2: Class + GO Button
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<ListDataa>(
                    value: controller.selectedClass.value,
                    isExpanded: true,
                    style: dropdownTextStyle,
                    items: controller.classList
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.className ?? '', style: dropdownTextStyle),
                    ))
                        .toList(),
                    onChanged: controller.setSelectedClass,
                    decoration: _dec("Class *"),
                  );
                }),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      controller.Fetchfeereport(); // Trigger fetch on GO button press
                    },
                    child: Text(
                      "GO",
                      style: TextStyle(
                        fontSize: 20.sp, // Larger GO button text
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
