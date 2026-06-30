import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/view_expenses_controller.dart';

class ViewExpensesScreen extends GetView<ViewExpensesController> {
  const ViewExpensesScreen({super.key});

  static const _teal = Color(0xFF00695C); // teal.shade800

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Text(
          "View Expenses",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: _teal,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Card ──────────────────────────────────────────────
            _FilterCard(controller: controller),
            SizedBox(height: 14.h),

            // ── Table / Empty / Loader ───────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.items.isEmpty) {
                  return _EmptyState();
                }
                return _ExpensesTable(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Card
// ─────────────────────────────────────────────────────────────────────────────
class _FilterCard extends StatelessWidget {
  final ViewExpensesController controller;
  const _FilterCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _DateField(
              label: "Start Date",
              value: controller.fmtUi(controller.startDate.value),
              onTap: () => controller.pickStartDate(context),
            )),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(() => _DateField(
              label: "End Date",
              value: controller.fmtUi(controller.endDate.value),
              onTap: () => controller.pickEndDate(context),
            )),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: controller.fetchExpenses,
              child: Text(
                "Search",
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date Field widget
// ─────────────────────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateField(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.black.withOpacity(0.13)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value,
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            "No expenses found",
            style: TextStyle(
                fontSize: 15.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 6.h),
          Text(
            "Select date range and tap Search",
            style: TextStyle(
                fontSize: 12.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expenses Table
// ─────────────────────────────────────────────────────────────────────────────
class _ExpensesTable extends StatelessWidget {
  final ViewExpensesController controller;
  const _ExpensesTable({required this.controller});

  // Column configs: (label, flex)
  static const List<(String, int)> _cols = [
    ("S.No",        1),
    ("Description", 3),
    ("Category",    2),
    ("Pay Mode",    2),
    ("Amount",      2),
    ("Date",        2),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
            ),
            child: Row(
              children: _cols
                  .map((c) => _HeaderCell(label: c.$1, flex: c.$2))
                  .toList(),
            ),
          ),

          // ── Rows ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() => ListView.separated(
              itemCount: controller.items.length + 1, // +1 total row
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                // Total row (last)
                if (index == controller.items.length) {
                  return _TotalRow(total: controller.grandTotal);
                }

                final item  = controller.items[index];
                final isEven = index % 2 == 0;

                return Container(
                  color: isEven
                      ? Colors.grey.shade50
                      : Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    children: [
                      _DataCell(
                          text: (index + 1).toString(), flex: 1),
                      _DataCell(
                          text: item.description, flex: 3),
                      _DataCell(
                          text: item.addECategory, flex: 2),
                      _DataCell(
                          text: item.paymentName, flex: 2),
                      _DataCell(
                        text: item.amount.toStringAsFixed(0),
                        flex: 2,
                        color: Colors.green.shade700,
                        bold: true,
                      ),
                      _DataCell(
                          text: item.formattedDate, flex: 2),
                    ],
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Total Row
// ─────────────────────────────────────────────────────────────────────────────
class _TotalRow extends StatelessWidget {
  final double total;
  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
      ),
      child: Row(
        children: [
          // S.No + Description + Category + Pay Mode = flex 1+3+2+2 = 8
          Expanded(
            flex: 8,
            child: Text(
              "Total",
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87),
            ),
          ),
          // Amount = flex 2
          Expanded(
            flex: 2,
            child: Text(
              total.toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade800),
            ),
          ),
          // Date = flex 2
          const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable cell widgets
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool bold;
  final Color? color;
  const _DataCell(
      {required this.text,
        required this.flex,
        this.bold = false,
        this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text.isEmpty ? '-' : text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: color ?? Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}