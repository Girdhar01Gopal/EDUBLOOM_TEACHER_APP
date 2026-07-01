import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/viewtransaction.dart';
import '../models/viewfeesmodel.dart';
import 'feereceiptprintscreen.dart';

String formatDate(String dateStr) {
  try {
    final dateTime = DateTime.parse(dateStr);
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  } catch (e) {
    return dateStr;
  }
}

class Viewtransactionview extends GetView<Viewtransactioncontroller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          "Transaction History",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF97144D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Obx(() {
        if (controller.transactionItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No transaction data available",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Individual cards — no grouping, same count as API returns
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          itemCount: controller.transactionItems.length,
          itemBuilder: (context, index) {
            final item = controller.transactionItems[index];
            return _TransactionCard(
              item: item,
              studentId: controller.studentId,
              session: controller.session,
            );
          },
        );
      }),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final fListData item;
  final int studentId;
  final String session;

  const _TransactionCard({
    required this.item,
    required this.studentId,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar ──
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF97144D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt, color: Colors.white70, size: 17),
                    const SizedBox(width: 7),
                    Text(
                      "Receipt: ${item.receiptno ?? 'N/A'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.paymentMode ?? 'N/A',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── Student info row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: const Color(0xFFF3E0E8),
                  child: Text(
                    (item.studentName ?? 'S')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF97144D),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.className ?? ''} | ${item.session ?? ''}",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.payDate != null ? formatDate(item.payDate!) : 'N/A',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Divider(height: 1, color: Color(0xFFE8EAF6)),
          ),

          // ── Fee details rows ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _detailRow("Fee Type", item.feeType ?? 'N/A'),
                const SizedBox(height: 5),
                _detailRow("Fee Month", item.feeMonth ?? 'N/A'),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                        child: _detailRow(
                            "Amount", "₹${item.totalAmount ?? 0}")),
                    Expanded(
                        child: _detailRow(
                            "Discount", "₹${item.discount ?? 0}",
                            valueColor: const Color(0xFFE53935))),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                        child: _detailRow("Paid", "₹${item.payAmount ?? 0}",
                            valueColor: const Color(0xFF2E7D32),
                            valueBold: true)),
                    Expanded(
                        child: _detailRow(
                            "Due", "₹${item.dueAmount ?? 0}",
                            valueColor: (item.dueAmount ?? 0) > 0
                                ? const Color(0xFFE53935)
                                : Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Divider(height: 1, color: Color(0xFFE8EAF6)),
          ),

          // ── Bottom: print button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fee month badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E0E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.feeMonth ?? '',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF97144D),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                // Yellow Print button
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(
                          () => const FeeReceiptPrintScreen(),
                      arguments: {
                        'studentId': studentId,
                        'session': session,
                        'receiptNo': item.receiptno ?? '',
                      },
                    );
                  },
                  icon: const Icon(Icons.print, size: 17,
                      color: Color(0xFF37474F)),
                  label: const Text(
                    "Print",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF37474F)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: const Color(0xFF37474F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? const Color(0xFF37474F),
              fontWeight:
              valueBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}