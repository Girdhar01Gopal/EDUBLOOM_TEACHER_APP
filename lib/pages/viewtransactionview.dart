import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/viewtransaction.dart';
import '../models/viewfeesmodel.dart';
import 'feereceiptprintscreen.dart';

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);
const Color kAxisMaroonLight = Color(0xFFF7E3EC); // light tint for backgrounds

String formatDate(String dateStr) {
  try {
    final dateTime = DateTime.parse(dateStr);
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  } catch (e) {
    return dateStr;
  }
}

String formatTime(String dateStr) {
  try {
    final dateTime = DateTime.parse(dateStr);
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  } catch (e) {
    return '';
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
        backgroundColor: kAxisMaroon,
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

// ── Group items by receiptno ──
        // Same receiptno => merged into a single card with combined data.
        // Different receiptno => shown individually, exactly as before.
        final Map<String, List<fListData>> grouped = <String, List<fListData>>{};
        for (final item in controller.transactionItems) {
          final key = item.receiptno ?? '';
          grouped.putIfAbsent(key, () => <fListData>[]).add(item);
        }
        final groupedList = grouped.values.toList();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          itemCount: groupedList.length,
          itemBuilder: (context, index) {
            final groupItems = groupedList[index];
            return _TransactionCard(
              items: groupItems,
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
  final List<fListData> items;
  final int studentId;
  final String session;

  const _TransactionCard({
    required this.items,
    required this.studentId,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final item = items.first; // header/student info comes from the first entry
    final bool isMerged = items.length > 1;

    // Totals across merged entries (used only when isMerged == true)
    double totalAmount = 0, totalDiscount = 0, totalPaid = 0, totalDue = 0;
    for (final it in items) {
      totalAmount += (it.totalAmount ?? 0);
      totalDiscount += (it.discount ?? 0);
      totalPaid += (it.payAmount ?? 0);
      totalDue += (it.dueAmount ?? 0);
    }
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
              color: kAxisMaroon,
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
                  backgroundColor: kAxisMaroonLight,
                  child: Text(
                    (item.studentName ?? 'S')[0].toUpperCase(),
                    style: const TextStyle(
                      color: kAxisMaroon,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.payDate != null ? formatDate(item.payDate!) : 'N/A',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                    if (item.createDate != null) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatTime(item.createDate!),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
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
              children: isMerged
                  ? _buildMergedFeeRows(totalAmount, totalDiscount, totalPaid, totalDue)
                  : _buildSingleFeeRows(item),
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
                    color: kAxisMaroonLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isMerged ? "${items.length} Fees" : (item.feeMonth ?? ''),
                    style: const TextStyle(
                        fontSize: 12,
                        color: kAxisMaroon,
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

// Same as the original single-item rows (used when receiptno has only 1 entry)
  List<Widget> _buildSingleFeeRows(fListData item) {
    return [
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
      const SizedBox(height: 5),   // 🆕 add this
      _detailRow("Admission No", item.admissionNo ?? 'N/A'),

    ];
  }

  // Merged rows: same row style as single, repeated per fee item, then totals at the end.
  List<Widget> _buildMergedFeeRows(
      double totalAmount, double totalDiscount, double totalPaid, double totalDue) {
    final List<Widget> rows = [];

    for (int i = 0; i < items.length; i++) {
      final it = items[i];
      if (i > 0) {
        rows.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ));
      }
      rows.addAll([
        _detailRow("Fee Type", it.feeType ?? 'N/A'),
        const SizedBox(height: 5),
        _detailRow("Fee Month", it.feeMonth ?? 'N/A'),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
                child: _detailRow(
                    "Amount", "₹${it.totalAmount ?? 0}")),
            Expanded(
                child: _detailRow(
                    "Discount", "₹${it.discount ?? 0}",
                    valueColor: const Color(0xFFE53935))),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
                child: _detailRow("Paid", "₹${it.payAmount ?? 0}",
                    valueColor: const Color(0xFF2E7D32),
                    valueBold: true)),
            Expanded(
                child: _detailRow(
                    "Due", "₹${it.dueAmount ?? 0}",
                    valueColor: (it.dueAmount ?? 0) > 0
                        ? const Color(0xFFE53935)
                        : Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 5),   // 🆕 add this
        _detailRow("Admission No", it.admissionNo ?? 'N/A'),

      ]);
    }

    // Totals summary for the merged receipt
    rows.addAll([
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 9),
        child: Divider(height: 1, color: Color(0xFFE8EAF6)),
      ),
      Row(
        children: [
          Expanded(
              child: _detailRow(
                  "Total Amount", "₹${totalAmount.toStringAsFixed(0)}",
                  valueBold: true)),
          Expanded(
              child: _detailRow(
                  "Total Discount", "₹${totalDiscount.toStringAsFixed(0)}",
                  valueColor: const Color(0xFFE53935), valueBold: true)),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(
              child: _detailRow(
                  "Total Paid", "₹${totalPaid.toStringAsFixed(0)}",
                  valueColor: const Color(0xFF2E7D32), valueBold: true)),
          Expanded(
              child: _detailRow(
                  "Total Due", "₹${totalDue.toStringAsFixed(0)}",
                  valueColor: totalDue > 0
                      ? const Color(0xFFE53935)
                      : Colors.grey.shade600,
                  valueBold: true)),
        ],
      ),
    ]);

    return rows;
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