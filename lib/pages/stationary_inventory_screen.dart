import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/stationary_inventory_controller.dart';

class StationaryInventoryScreen extends StatelessWidget {
  const StationaryInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF6E0F38);
    final controller = Get.put(StationaryInventoryController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Stationary Inventory Data",
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchInventoryData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: controller.exportAndSharePdf,
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
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
                  return _errorBox(
                    controller.errorMsg.value,
                    controller.fetchInventoryData,
                  );
                }

                final list = controller.visibleList;

                if (list.isEmpty) {
                  return _emptyBox(controller.fetchInventoryData);
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchInventoryData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: teal.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: teal,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                              ),
                            ),
                            child: Row(
                              children: [
                                _headerCell("S.No", 1),
                                _headerCell("Product", 3),
                                _headerCell("Total Qty", 2,
                                    textAlign: TextAlign.right),
                                _headerCell("Balance Qty", 2,
                                    textAlign: TextAlign.right),
                              ],
                            ),
                          ),
                          ListView.separated(
                            itemCount: list.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                            itemBuilder: (context, i) {
                              final item = list[i];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 14.h,
                                ),
                                child: Row(
                                  children: [
                                    _bodyCell("${i + 1}", 1),
                                    _bodyCell(item.productName, 3),
                                    _bodyCell(
                                      item.totalQuantity.toString(),
                                      2,
                                      textAlign: TextAlign.right,
                                    ),
                                    _bodyCell(
                                      item.balanceQuantity.toString(),
                                      2,
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(
      Color teal,
      StationaryInventoryController controller,
      ) {
    return TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      decoration: InputDecoration(
        hintText: "Search product / quantity",
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: teal.withOpacity(0.20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: teal),
        ),
      ),
    );
  }

  Widget _headerCell(
      String text,
      int flex, {
        TextAlign textAlign = TextAlign.left,
      }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _bodyCell(
      String text,
      int flex, {
        TextAlign textAlign = TextAlign.left,
      }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
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
          const Text("No inventory records found"),
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
}