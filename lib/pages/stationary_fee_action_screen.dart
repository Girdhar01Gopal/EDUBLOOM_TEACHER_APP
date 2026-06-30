import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/stationary_fee_action_controller.dart';

class StationaryFeeActionScreen extends GetView<StationaryFeeActionController> {
  const StationaryFeeActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      appBar: AppBar(
        title: const Text(
          '🎓 Stationary fee action',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentHeader(),
                  const SizedBox(height: 16),
                  _buildFormCard(context, isMobile),
                  const SizedBox(height: 18),
                  _buildHistoryCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Obx(
          () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: controller.isLoadingStudent.value
            ? const Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
            : Text(
          'Student Name: ${controller.studentName.value.isEmpty ? '-' : controller.studentName.value}, '
              'Class/Sec: ${controller.classSection.value.isEmpty ? '-' : controller.classSection.value}, '
              'Session: ${controller.session.value.isEmpty ? '-' : controller.session.value}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildTopTable(),
          const SizedBox(height: 16),
          _buildDateRow(context, isMobile),
          const SizedBox(height: 12),
          _buildPaymentModeRow(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 110,
              height: 42,
              child: Obx(
                    () => ElevatedButton(
                  onPressed: controller.isSubmittingPayment.value
                      ? null
                      : controller.payNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0d6efd),
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isSubmittingPayment.value
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Pay now'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTable() {
    return Obx(() {
      if (controller.isLoadingStationary.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.stationaryItems.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No stationary items found',
            style: TextStyle(fontSize: 14),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900),
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                        width: 60,
                        child: Text('S.No', style: _headerStyle)),
                    SizedBox(
                        width: 200,
                        child: Text('Stationary', style: _headerStyle)),
                    SizedBox(
                        width: 180,
                        child: Text('Total Quantity', style: _headerStyle)),
                    SizedBox(
                        width: 160,
                        child: Text('Quantity', style: _headerStyle)),
                    SizedBox(width: 10),
                    SizedBox(
                        width: 200,
                        child: Text('Pay Amount', style: _headerStyle)),
                  ],
                ),
              ),
              ...controller.stationaryItems.map(
                    (item) => Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 60, child: Text('${item.id}')),
                      SizedBox(width: 200, child: Text(item.stationaryName)),
                      SizedBox(
                          width: 180,
                          child: Text('${item.totalQuantity}')),
                      SizedBox(
                        width: 160,
                        child: _textField(
                          controller: item.quantityController,
                          hint: 'Quantity',
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 200,
                        child: _textField(
                          controller: item.payAmountController,
                          hint: 'Pay Amount',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDateRow(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Obx(
            () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => controller.pickDate(context),
              child: IgnorePointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: controller.selectedDate.value,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Obx(
          () => Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => controller.pickDate(context),
              child: IgnorePointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: controller.selectedDate.value,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    suffixIcon: const Icon(Icons.calendar_month),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeRow() {
    return Obx(() {
      if (controller.isLoadingPaymentModes.value) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Mode',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Mode',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: controller.selectedPaymentMode.value.isEmpty
                ? null
                : controller.selectedPaymentMode.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12),
            ),
            hint: const Text('Please Select Payment Mode'),
            items: controller.paymentModes
                .map((item) {
              final value = item.toString().trim();
              if (value.isEmpty) return null;
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            })
                .whereType<DropdownMenuItem<String>>()
                .toList(),
            onChanged: (value) {
              controller.selectedPaymentMode.value = value ?? '';
              controller.onPaymentModeChanged(value);
            },
          ),
        ],
      );
    });
  }

  // ── UPDATED history card with Action column ────────────────
  Widget _buildHistoryCard(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPaymentHistory.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor:
                  WidgetStateProperty.all(Colors.grey.shade200),
                  columnSpacing: 18,
                  columns: const [
                    DataColumn(label: Text('S.No')),
                    DataColumn(label: Text('Student Id')),
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Class/Section')),
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Pay Date')),
                    DataColumn(label: Text('Payment Mode')),
                    DataColumn(label: Text('Pay Amount')),
                    DataColumn(label: Text('Receipt No.')),
                    DataColumn(label: Text('Action')), // ← NEW
                  ],
                  rows: controller.paymentHistory.isEmpty
                      ? [
                    const DataRow(
                      cells: [
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('No data found')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')), // ← NEW
                      ],
                    ),
                  ]
                      : List.generate(
                    controller.paymentHistory.length,
                        (index) {
                      final item =
                      controller.paymentHistory[index];
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(item.studentId)),
                          DataCell(Text(item.studentName)),
                          DataCell(Text(item.classSection)),
                          DataCell(Text(item.product)),
                          DataCell(Text(item.payDate)),
                          DataCell(Text(item.paymentMode)),
                          DataCell(Text(item.payAmount)),
                          DataCell(Text(item.receiptNo)),
                          // ── Print button ──────────────
                          DataCell(
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.onPrint(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.amber.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets
                                      .symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Print',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
  }) {
    return SizedBox(
      height: 42,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 15,
);