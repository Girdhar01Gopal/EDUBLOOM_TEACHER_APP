import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/pay_daycare_controller.dart';
import '../infrastructures/routes/page_constants.dart';

class PayDayCScreen extends StatelessWidget {
  final PayDayCController controller = Get.put(PayDayCController());

  PayDayCScreen({Key? key}) : super(key: key);

  Future<void> _refresh() async {
    await controller.fetchFees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "DayCare Fee's",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade800, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 8,
        shadowColor: Colors.teal.withOpacity(0.4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(
                  RouteName.daycarefeepaymentview,
                  arguments: {
                    'registrationNo': controller.registerationNo.value.toString(),
                    'session': controller.session.value,
                    'schoolId': controller.schoolId.value,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade800,
                elevation: 4,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.white.withOpacity(0.3),
              ),
              child: const Text(
                "Transactions",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Data Table Card
                    Card(
                      elevation: 8,
                      shadowColor: Colors.teal.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.teal.shade50.withOpacity(0.5)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.table_chart,
                                          color: Colors.teal.shade700,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Fee Details",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.teal.shade900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 20),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Obx(() {
                                  return DataTable(
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          "Select",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "S.No",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Fee Type",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Login",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Logout",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Hours",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Amount",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Status",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: controller.filteredFeeDataList
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key + 1;
                                      var data = entry.value;
                                      bool isEvenRow = index % 2 == 0;

                                      String displayTotalHours = controller
                                          .getCalculatedTotalHours(data);

                                      int calculatedAmount =
                                          controller.calculateRowTotalPay(data);

                                      bool isFullyPaid =
                                          controller.isPaymentStatusPaid(data);

                                      return DataRow(
                                        color:
                                            MaterialStateProperty.resolveWith(
                                          (states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors.teal.shade100;
                                            }
                                            return isEvenRow
                                                ? Colors.grey.shade50
                                                : Colors.white;
                                          },
                                        ),
                                        cells: [
                                          DataCell(
                                            isFullyPaid
                                                ? Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade400,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.green
                                                              .withOpacity(0.3),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                              0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 16),
                                                  )
                                                : Checkbox(
                                                    value: controller
                                                        .selectedRows
                                                        .contains(data),
                                                    onChanged: (isSelected) {
                                                      controller
                                                          .toggleRowSelection(
                                                              data,
                                                              isSelected ??
                                                                  false);
                                                    },
                                                    activeColor:
                                                        Colors.teal.shade700,
                                                  ),
                                          ),
                                          DataCell(
                                            Text(
                                              index.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(
                                            data.feeTypeName ?? '--',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          )),
                                          DataCell(Text(
                                            data.fromTime ?? '--',
                                            style:
                                                const TextStyle(fontSize: 13),
                                          )),
                                          DataCell(Text(
                                            data.toTime ?? '--',
                                            style:
                                                const TextStyle(fontSize: 13),
                                          )),
                                          DataCell(
                                            Obx(
                                              () => Text(
                                                controller.selectedRows
                                                        .contains(data)
                                                    ? displayTotalHours
                                                    : (data.totalHour ??
                                                        '0:00'),
                                                style: TextStyle(
                                                  fontWeight: controller
                                                          .selectedRows
                                                          .contains(data)
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: controller.selectedRows
                                                          .contains(data)
                                                      ? Colors.blue.shade700
                                                      : Colors.black87,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              data.totalAmount != null
                                                  ? "₹${data.totalAmount}"
                                                  : '--',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isFullyPaid
                                                    ? Colors.green.shade100
                                                    : Colors.orange.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isFullyPaid
                                                      ? Colors.green.shade500
                                                      : Colors.orange.shade500,
                                                  width: 1.2,
                                                ),
                                              ),
                                              child: Text(
                                                isFullyPaid
                                                    ? 'PAID'
                                                    : 'PENDING',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: isFullyPaid
                                                      ? Colors.green.shade900
                                                      : Colors.orange.shade900,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Summary Section
                    _buildSummarySection(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ Baaki sab same (tumhara original code)
  Widget _buildSummarySection() {
    return Card(
      elevation: 10,
      shadowColor: Colors.teal.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.teal.shade50.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.teal.shade100,
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final hasSelection = controller.selectedRows.isNotEmpty;

            final modes = controller.paymentModes
                .where((m) => (m.paymentMode ?? '').trim().isNotEmpty)
                .toList();

            final items = modes.isEmpty
                ? const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: '',
                      enabled: false,
                      child: Text("No payment modes"),
                    ),
                  ]
                : modes
                    .map((m) => DropdownMenuItem<String>(
                          value: m.paymentMode!,
                          child: Text(m.paymentMode!,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList();

            final selectedMode = controller.selectedPaymentMode.value.trim();
            final modeUpper = selectedMode.toUpperCase();
            final paymentModeSelected = selectedMode.isNotEmpty;

            bool extraFieldsOk = true;

            if (modeUpper == "NEFT" ||
                modeUpper == "RTGS" ||
                modeUpper == "IMPS") {
              extraFieldsOk =
                  controller.bankNameController.text.trim().isNotEmpty &&
                      controller.chequeNoController.text.trim().isNotEmpty &&
                      controller.chequeDateController.text.trim().isNotEmpty;
            } else if (modeUpper == "UPI") {
              extraFieldsOk =
                  controller.upiTxnController.text.trim().isNotEmpty;
            }

            final canPay = hasSelection && paymentModeSelected && extraFieldsOk;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasSelection)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Select at least one row to proceed with payment",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!hasSelection) const SizedBox(height: 16),
                _buildSummaryRow(
                  icon: Icons.checklist_rtl,
                  label: "Selected Rows",
                  value: "${controller.selectedRows.length} selected",
                  color: Colors.blue,
                ),
                _buildSummaryRow(
                  icon: Icons.category,
                  label: "Fee Type/Month",
                  value: hasSelection
                      ? controller.getSelectedFeeTypeMonth()
                      : "--",
                  color: Colors.purple,
                ),
                _buildSummaryRow(
                  icon: Icons.trending_down,
                  label: "Total Due Amount",
                  value:
                      "₹${controller.getTotalDueAmount().toStringAsFixed(0)}",
                  color: Colors.orange,
                ),
                _buildSummaryRow(
                  icon: Icons.attach_money,
                  label: "Total Amount",
                  value: "₹${controller.getTotalAmount().toStringAsFixed(0)}",
                  color: Colors.teal,
                  isBold: true,
                ),
                if (controller.getdiscount() != 0)
                  _buildSummaryRow(
                    icon: Icons.discount,
                    label: "Discount Amount",
                    value: "₹${controller.getdiscount().toStringAsFixed(0)}",
                    color: Colors.green,
                  ),
                const SizedBox(height: 16),
                Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.withOpacity(0.2),
                        Colors.teal.withOpacity(0.5),
                        Colors.teal.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.getdiscount() == 0) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Flexible(
                        flex: 2,
                        child: Text(
                          "Discount",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        flex: 3,
                        child: TextFormField(
                          controller: controller.discountAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: "0",
                            prefixIcon: const Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.teal.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.teal.shade600,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            filled: true,
                            fillColor: Colors.teal.shade50.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        "Total Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: controller.totalPayController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0",
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.teal.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade600,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          filled: true,
                          fillColor: Colors.teal.shade50.withOpacity(0.3),
                        ),
                        onChanged: (value) {
                          controller.totalPay.value =
                              int.tryParse(value) ?? controller.totalPay.value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Text(
                        "Payment Mode",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedMode.isEmpty ? null : selectedMode,
                        decoration: InputDecoration(
                          hintText: 'Select payment method',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.teal.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade600,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          filled: true,
                          fillColor: Colors.teal.shade50.withOpacity(0.3),
                          prefixIcon: Icon(
                            Icons.payment,
                            color: Colors.teal.shade600,
                          ),
                        ),
                        items: items,
                        onChanged: modes.isEmpty
                            ? null
                            : (value) {
                                controller.selectedPaymentMode.value =
                                    (value ?? '').trim();
                                final m = controller.selectedPaymentMode.value
                                    .toUpperCase();
                                if (m == "CASH") {
                                  controller.bankNameController.clear();
                                  controller.chequeNoController.clear();
                                  controller.chequeDateController.clear();
                                  controller.upiTxnController.clear();
                                } else if (m == "UPI") {
                                  controller.bankNameController.clear();
                                  controller.chequeNoController.clear();
                                  controller.chequeDateController.clear();
                                } else if (m == "NEFT" ||
                                    m == "RTGS" ||
                                    m == "IMPS") {
                                  controller.upiTxnController.clear();
                                }
                              },
                      ),
                    ),
                  ],
                ),
                if (modeUpper == "NEFT" ||
                    modeUpper == "RTGS" ||
                    modeUpper == "IMPS") ...[
                  _field(
                    label: "Bank Name",
                    controller: controller.bankNameController,
                    hint: "Enter bank name",
                    icon: Icons.account_balance,
                  ),
                  _field(
                    label: "UTR / Reference No",
                    controller: controller.chequeNoController,
                    hint: "Enter UTR",
                    icon: Icons.confirmation_number,
                  ),
                  _field(
                    label: "Transfer Date (YYYY-MM-DD)",
                    controller: controller.chequeDateController,
                    hint: "2025-12-29",
                    keyboardType: TextInputType.datetime,
                    icon: Icons.calendar_month,
                  ),
                ],
                if (modeUpper == "UPI") ...[
                  _field(
                    label: "UPI Transaction ID",
                    controller: controller.upiTxnController,
                    hint: "Enter txn id",
                    icon: Icons.qr_code_2,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade600,
                              Colors.teal.shade800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: canPay
                              ? () async {
                                  await controller.addFees();
                                  await _refresh();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          icon: const Icon(Icons.payment, size: 22),
                          label: Text(
                            canPay ? "Pay Fees" : "Fill Details",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.cancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(
                            color: Colors.red.shade400,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.red.shade50,
                        ),
                        icon: const Icon(Icons.close, size: 22),
                        label: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade700,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: Colors.teal.shade600,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.teal.shade600,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade200),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Colors.teal.shade50.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    IconData? icon,
    Color color = Colors.teal,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              fontSize: isBold ? 16 : 15,
              color: isBold ? Colors.teal.shade900 : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxPayFormatter extends TextInputFormatter {
  _MaxPayFormatter(this.getMax);
  final int Function() getMax;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text.trim();
    if (t.isEmpty) return newValue;

    final v = int.tryParse(t);
    if (v == null) return oldValue;

    final max = getMax();
    if (v > max) {
      final capped = max.toString();
      return TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    return newValue;
  }
}
