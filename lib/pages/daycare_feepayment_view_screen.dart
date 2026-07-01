// screens/daycare_fee_payment_screen.dart  (UPDATED)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/daycare_feepayment_view_controller.dart';
import '../models/daycarefeespaymentmodel.dart';
import 'dadycare_receipt_payment_screen.dart';

class DaycareFeePaymentScreen extends StatelessWidget {
  DaycareFeePaymentScreen({super.key});

  final DaycareFeePaymentviewController c =
  Get.put(DaycareFeePaymentviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF97144D),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          "Day Care Transactions",
          style: TextStyle(
            color:         Colors.white,
            fontWeight:    FontWeight.w700,
            fontSize:      18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF97144D)),
          );
        }

        if (c.error.value.isNotEmpty) {
          return _ErrorView(
            message: c.error.value,
            onRetry: () => c.fetchPayments(
              registrationNo: c.registrationNo.value,
              session:        c.session.value,
              schoolId:       c.schoolId.value,
            ),
          );
        }

        if (c.payments.isEmpty) {
          return _EmptyView(
            onRefresh: () => c.fetchPayments(
              registrationNo: c.registrationNo.value,
              session:        c.session.value,
              schoolId:       c.schoolId.value,
            ),
          );
        }

        return RefreshIndicator(
          color:     const Color(0xFF97144D),
          onRefresh: () => c.fetchPayments(
            registrationNo: c.registrationNo.value,
            session:        c.session.value,
            schoolId:       c.schoolId.value,
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            children: [
              _SummaryCard(items: c.payments),
              const SizedBox(height: 16),
              ...c.payments.asMap().entries.map(
                    (entry) => _TransactionCard(
                  item:             entry.value,
                  index:            entry.key,
                  // ✅ Prefer studentId from item; fallback to controller
                  studentId:        entry.value.studentId ?? c.studentId.value,
                  session:          c.session.value,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Summary KPI Card ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final List<TransactionItem> items;
  const _SummaryCard({required this.items});

  @override
  Widget build(BuildContext context) {
    double total = 0, paid = 0, due = 0, disc = 0;
    for (final item in items) {
      total += item.totalAmount ?? 0;
      paid  += item.payAmount   ?? 0;
      due   += item.dueAmount   ?? 0;
      disc  += item.discount    ?? 0;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF97144D), Color(0xFF4A0E29)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFF97144D).withOpacity(0.35),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary",
            style: TextStyle(
              color:         Colors.white70,
              fontSize:      13,
              fontWeight:    FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _kpi("Total",    total, Colors.white)),
              Expanded(child: _kpi("Paid",     paid,  const Color(0xFFF48FB1))),
              Expanded(child: _kpi("Due",      due,   const Color(0xFFFF8A80))),
              Expanded(child: _kpi("Discount", disc,  const Color(0xFFFFD180))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color:      Colors.white60,
                fontSize:   11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          "₹${val.toStringAsFixed(0)}",
          style: TextStyle(
              color:      color,
              fontSize:   16,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ─── Individual Transaction Card ───────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionItem item;
  final int             index;
  final int             studentId;  // resolved: item.studentId ?? controller.studentId
  final String          session;

  const _TransactionCard({
    required this.item,
    required this.index,
    required this.studentId,
    required this.session,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('dd-MM-yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = (item.dueAmount ?? 0) == 0 && (item.payAmount ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF97144D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        color: Colors.white70, size: 17),
                    const SizedBox(width: 7),
                    Text(
                      "Receipt: ${item.receiptno ?? 'N/A'}",
                      style: const TextStyle(
                        color:         Colors.white,
                        fontWeight:    FontWeight.w700,
                        fontSize:      14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withOpacity(0.25)
                        : Colors.orange.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    isPaid ? "PAID" : "PENDING",
                    style: TextStyle(
                      color:      isPaid ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Payment Mode & Date ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment,
                        size: 15, color: Color(0xFF97144D)),
                    const SizedBox(width: 5),
                    Text(
                      item.paymentMode ?? 'N/A',
                      style: const TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      Color(0xFF97144D),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(item.payDate),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Divider(height: 1, color: Color(0xFFE8EAF6)),
          ),

          // ── Fee Details ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 5),
                _detailRow("Fee Month", item.feeMonth ?? 'N/A'),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: _detailRow("Total",
                          "₹${(item.totalAmount ?? 0).toStringAsFixed(0)}"),
                    ),
                    Expanded(
                      child: _detailRow(
                          "Discount",
                          "₹${(item.discount ?? 0).toStringAsFixed(0)}",
                          valueColor: const Color(0xFFE53935)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: _detailRow(
                          "Paid",
                          "₹${(item.payAmount ?? 0).toStringAsFixed(0)}",
                          valueColor: const Color(0xFF2E7D32),
                          valueBold:  true),
                    ),
                    Expanded(
                      child: _detailRow(
                          "Due",
                          "₹${(item.dueAmount ?? 0).toStringAsFixed(0)}",
                          valueColor: (item.dueAmount ?? 0) > 0
                              ? const Color(0xFFE53935)
                              : Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Divider(height: 1, color: Color(0xFFE8EAF6)),
          ),

          // ── Footer: badge + Print ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFFDF0F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.feeMonth ?? '',
                    style: const TextStyle(
                        fontSize:   12,
                        color:      Color(0xFF97144D),
                        fontWeight: FontWeight.w600),
                  ),
                ),

                // ── Print button ──
                ElevatedButton.icon(
                  onPressed: () {
                    final receiptNo = item.receiptno ?? '';
                    if (receiptNo.isEmpty) {
                      Get.snackbar(
                        "No Receipt",
                        "Receipt number not available.",
                        snackPosition:   SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.shade100,
                        colorText:       Colors.red.shade800,
                      );
                      return;
                    }
                    // ✅ studentId from item (most reliable), session from controller
                    Get.to(
                          () => const DaycareFeeReceiptPrintScreen(),
                      arguments: {
                        'studentId': studentId,   // int
                        'session':   session,      // string
                        'receiptNo': receiptNo,    // string
                      },
                    );
                  },
                  icon: const Icon(Icons.print,
                      size: 17, color: Color(0xFF37474F)),
                  label: const Text(
                    "Print",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   13,
                        color:      Color(0xFF37474F)),
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
              fontSize:   13,
              color:      Colors.grey.shade600,
              fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize:   13,
              color:      valueColor ?? const Color(0xFF37474F),
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF97144D),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color:     const Color(0xFF97144D),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 14),
                Text(
                  "No payment records found.",
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pull down to refresh",
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}