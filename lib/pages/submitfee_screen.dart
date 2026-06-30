import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/submitFeeC.dart';
import '../infrastructures/routes/page_constants.dart';
import '../models/student_fee_model.dart';

class SubmitFeeScreen extends GetView<SubmitFeeController> {
  const SubmitFeeScreen({super.key});

  String _norm(String s) => s.trim().toUpperCase();

  @override
  Widget build(BuildContext context) {
    // Refresh data when screen is built (e.g., after returning from payment)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fees for Student",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Obx(() => controller.selectedRows.isNotEmpty
                ? Text(
                    "${controller.selectedRows.length} fee(s) selected",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 37, 80, 76),
        actions: [
          Obx(() => controller.selectedRows.length < 2
              ? InkWell(
                  onTap: () async {
                    final discountAmount = await Get.toNamed(
                      RouteName.add_discount,
                      arguments: {
                        'selectedRows': controller.selectedRows,
                        'studentId': controller.selectedStudentId.value,
                      },
                    );
                    if (discountAmount != null && discountAmount is int) {
                      controller.applyDiscountToSelectedFees(discountAmount);
                      await controller.refreshData();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_offer, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "Discount",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.feeItems.isEmpty) {
          return const Center(
            child: Text(
              "No fee data available",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        final first = controller.feeItems.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Student: ${first.studentName ?? 'N/A'} (${first.registrationNo ?? ''})",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Get.toNamed(RouteName.viewtransaction, arguments: {
                        'session': first.session,
                        'registrationNo': first.registrationNo,
                        'schoolId': first.schoolId,
                        'classId': int.tryParse(first.classId.toString()) ?? 0,
                        'sectionId': int.tryParse(first.sectionId.toString()) ?? 0,
                        'studentId': controller.selectedStudentId.value != 0
                            ? controller.selectedStudentId.value
                            : first.studentId,
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(7),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 37, 80, 76),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        "View Transactions",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Selection Summary Card
            Obx(() => controller.selectedRows.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade50,
                          Colors.teal.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade300, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade700,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${controller.selectedRows.length} Fee(s) Selected",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: controller.clearAllSelections,
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text("Clear All"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  "₹${controller.totalAmount.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade900,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Due Amount",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  "₹${controller.getSelectedDueTotal()}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.selectAllUnpaidFees,
                      icon: const Icon(Icons.select_all, size: 18),
                      label: const Text("Select All Unpaid"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal.shade700,
                        side: BorderSide(color: Colors.teal.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => controller.selectedRows.isNotEmpty
                      ? Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.clearAllSelections,
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text("Clear Selection"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Obx(() {
                    return DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => const Color.fromARGB(255, 37, 80, 76),
                      ),
                      columnSpacing: 18.0,
                      columns: _createTableColumns(),
                      rows: _createTableRows(controller),
                    );
                  }),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                // Get selected fee types as comma-separated string
                String selectedFeeTypes = controller.selectedRows
                    .map((item) => item.feeType ?? '')
                    .where((type) => type.isNotEmpty)
                    .toSet() // Remove duplicates
                    .join(', ');

                final int selectedDue = controller.getSelectedDueTotal();
                final bool hasSelection = controller.selectedRows.isNotEmpty;
            
                
                return Column(
                  children: [
                    // Payment Info Card
                    if (hasSelection)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Paying for: $selectedFeeTypes",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Pay Now Button
            SizedBox(
  width: double.infinity,
  height: 52.h,
  child: ElevatedButton(
    onPressed: hasSelection
        ? () => controller.showPaymentDetailsDialog(
              feesmonth: first.feesDuration.toString(),
              studentname: first.studentName ?? '',
              feetype: selectedFeeTypes,
              due: selectedDue,
           
            )
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal.shade700,
      disabledBackgroundColor: Colors.grey.shade300,
      elevation: hasSelection ? 4 : 0,
      shadowColor: Colors.teal.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasSelection ? Icons.payment : Icons.check_box_outline_blank,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          hasSelection
              ? (controller.selectedRows.length > 1
                  ? "Pay ₹${selectedDue > controller.totalAmount ? selectedDue : controller.totalAmount.toStringAsFixed(0)}"
                  : "Pay ₹${selectedDue > 0 ? selectedDue : controller.totalAmount.toStringAsFixed(0)}")
              : "Select Fees to Pay",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  ),
)
],
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  List<DataColumn> _createTableColumns() {
    return const [
      DataColumn(
        label: Text(
          'Select',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      DataColumn(
        label: Text(
          'Fee-Type/Duration',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      DataColumn(
        label: Text(
          'Amount',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // ✅ NEW
      DataColumn(
        label: Text(
          'Paid',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      DataColumn(
        label: Text(
          'Due Amount',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      DataColumn(
        label: Text(
          'Discount',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      // DataColumn(
      //   label: Text(
      //     'Status',
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      // ),
    ];
  }

  List<DataRow> _createTableRows(SubmitFeeController c) {
    return c.feeItems.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      // ✅ KEY MUST MATCH controller map:
      // '$feeMonth-$feeType' where feeMonth should match feesDuration
      final key =
          '${_norm(data.feesDuration ?? '')}-${_norm(data.feeType ?? '')}';

      // ✅ real values from API maps
      final due = c.dueAmounts[key] ?? 0;
      final paid = c.paidAmounts[key] ?? 0;

      final discount = data.discount ?? 0;
      final baseAmount = int.tryParse(data.amount) ?? 0;
      final check = baseAmount + discount;
      final status = c.status.value;
      print('Row $index: key=$key, baseAmount=$baseAmount, paid=$paid, due=$due, discount=$discount, status=$status');

      return DataRow(
        cells: [
          DataCell(
            baseAmount == paid
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade100, Colors.green.shade200],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade700, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'PAID',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: c.checkboxStates.length > index
                          ? c.checkboxStates[index]
                          : false,
                      onChanged: (value) => c.toggleCheckbox(index, value),
                      activeColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
          ),
          _buildCell('${data.feeType ?? 'N/A'}/${data.feesDuration ?? 'N/A'}'),
          _buildCell(baseAmount.toString(), isAmount: true),

          // ✅ NEW paid column
          _buildCell(paid.toString(), isAmount: true),

          // ✅ due from API
          _buildCell(due.toString(), isAmount: true),

          _buildCell(discount.toString(), isAmount: true),
         // _buildCell(status,isAmount: false),
        ],
      );
    }).toList();
  }

  DataCell _buildCell(String value, {bool isAmount = false}) {
    return DataCell(
      Text(
        isAmount ? '₹$value' : value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          color: isAmount ? Colors.green : Colors.black,
        ),
      ),
    );
  }
}