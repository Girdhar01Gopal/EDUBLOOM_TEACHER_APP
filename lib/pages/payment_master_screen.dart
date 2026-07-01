import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/payment_master_controller.dart';

class PaymentMasterScreen extends GetView<PaymentMasterController> {
  const PaymentMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Payment Master", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF6E0F38),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add"),
              Tab(icon: Icon(Icons.view_list), text: "View"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddPaymentTab(),
            ViewPaymentTab(),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// TAB 1: ADD
// ----------------------
class AddPaymentTab extends GetView<PaymentMasterController> {
  const AddPaymentTab({super.key});

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    filled: true,
    fillColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 12.h),

            TextField(
              controller: controller.paymentModeController,
              decoration: _dec("Payment Mode *"),
            ),
            SizedBox(height: 18.h),

            Obx(() {
              return SizedBox(
                width: 130.w,
                height: 46.h,
                child: ElevatedButton(
                  onPressed:
                  controller.isPosting.value ? null : controller.savePaymentMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: controller.isPosting.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// TAB 2: VIEW
// ----------------------
class ViewPaymentTab extends GetView<PaymentMasterController> {
  const ViewPaymentTab({super.key});

  InputDecoration _searchDec() => InputDecoration(
    hintText: "Search payment mode...",
    prefixIcon: const Icon(Icons.search),
    border: const OutlineInputBorder(),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  );

  String _fmtDate(dynamic dateVal) {
    if (dateVal == null) return "-";
    try {
      // payment_master model may keep it as String/DateTime
      final dt = dateVal is DateTime ? dateVal : DateTime.parse(dateVal.toString());
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      return "$d-$m-$y";
    } catch (_) {
      return "-";
    }
  }

  void _openEditDialog({required int id, required String currentMode}) {
    final ctrl = TextEditingController(text: currentMode);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Payment Mode"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: "Payment Mode",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          Obx(() {
            return ElevatedButton(
              onPressed: controller.isPosting.value
                  ? null
                  : () {
                final v = ctrl.text.trim();
                controller.updatePaymentMode(
                  paymentModeId: id,
                  paymentMode: v,
                );
              },
              child: controller.isPosting.value
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Update"),
            );
          }),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => controller.searchText.value = v,
                  decoration: _searchDec(),
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                height: 48.h,
                width: 48.h,
                child: IconButton(
                  onPressed: () => controller.fetchPaymentModes(),
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.filteredList;

              if (list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchPaymentModes(),
                  child: ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          "No payment modes found",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchPaymentModes(),
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) {
                    final item = list[i];
                    final isActive = item.action == "1";

                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: Colors.teal.shade50,
                            child: Icon(Icons.payment,  color: const Color(0xFF97144D),),
                          ),
                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.paymentMode,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),

                                // ✅ Created date dd-MM-yyyy
                                Text(
                                  "Created: ${_fmtDate(item.createDate)}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ✅ Edit icon
                          IconButton(
                            onPressed: () => _openEditDialog(
                              id: item.paymentModeId,
                              currentMode: item.paymentMode,
                            ),
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: "Edit",
                          ),

                          // ✅ Status badge (active/inactive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isActive ? "Active" : "Inactive",
                              style: TextStyle(
                                color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}