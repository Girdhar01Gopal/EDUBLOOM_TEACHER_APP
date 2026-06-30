import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/fee_payment_details_controller.dart';
import '../models/fee_payment_details_model.dart';

class FeePaymentDetailsScreen extends StatelessWidget {
  const FeePaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = Colors.teal.shade800;
    final controller = Get.put(FeePaymentDetailsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Fee Payment Details",
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchPaymentDetails,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            _searchBar(teal, controller),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMsg.value.isNotEmpty) {
                  return _errorBox(controller.errorMsg.value, controller.fetchPaymentDetails);
                }

                final list = controller.filteredPayments;
                if (list.isEmpty) {
                  return _emptyBox(controller.fetchPaymentDetails);
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchPaymentDetails,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, i) => _paymentCard(teal, list[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(Color teal, FeePaymentDetailsController controller) {
    return TextField(
      onChanged: controller.setSearch,
      decoration: InputDecoration(
        hintText: "🔎 Search: name / reg no / receipt / month / mode / fee type",
        prefixIcon: Icon(Icons.search, color: teal),
        suffixIcon: Obx(() {
          return controller.searchText.value.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
            onPressed: controller.clearSearch,
            icon: Icon(Icons.close, color: teal),
          );
        }),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: teal.withOpacity(0.25)),
        ),
      ),
    );
  }

  Widget _paymentCard(Color teal, FeePaymentModel p) {
    final payDate = p.payDate != null ? _formatDate(p.payDate!) : "-";

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: teal.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.studentName,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: teal.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  p.paymentMode,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: teal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text("Reg No: ${p.registrationNo}",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _chip(teal, "Month: ${p.feeMonth}"),
              _chip(teal, "Receipt: ${p.receiptNo}"),
              _chip(teal, "Date: $payDate"),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kv("Total", "₹${p.totalAmount}"),
              _kv("Paid", "₹${p.payAmount}"),
              _kv("Due", "₹${p.dueAmount}"),
              _kv("Disc", "₹${p.discount}"),
            ],
          ),
          SizedBox(height: 10.h),
          Text("Fee Type: ${p.feetype.isEmpty ? '-' : p.feetype}",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _chip(Color teal, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: teal.withOpacity(0.15)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
        SizedBox(height: 2.h),
        Text(v, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _errorBox(String msg, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.red),
            SizedBox(height: 10.h),
            Text(msg, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 42),
          SizedBox(height: 10.h),
          const Text("No payment records found"),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$day-$m-$y";
  }
}
