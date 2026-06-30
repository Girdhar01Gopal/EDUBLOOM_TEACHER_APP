import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/product_quantity_controller.dart';
import '../models/product_quantity_model.dart';

class ProductQuantityScreen extends StatelessWidget {
  const ProductQuantityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          title: const Text(
            "Add Product Quantity",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add"),
              Tab(icon: Icon(Icons.view_list), text: "View"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddProductQuantityTab(),
            _ViewProductQuantityTab(),
          ],
        ),
      ),
    );
  }
}

class _AddProductQuantityTab extends GetView<ProductQuantityController> {
  const _AddProductQuantityTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Product Quantity",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 18.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isSmall = constraints.maxWidth < 700;

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _productDropdown(),
                          SizedBox(height: 16.h),
                          _quantityField(),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _productDropdown()),
                        SizedBox(width: 20.w),
                        Expanded(child: _quantityField()),
                      ],
                    );
                  },
                ),
                SizedBox(height: 30.h),
                Obx(() {
                  return SizedBox(
                    width: 115.w,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: controller.isPosting.value
                          ? null
                          : controller.addProductQuantity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5AC00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isPosting.value
                          ? SizedBox(
                        height: 18.sp,
                        width: 18.sp,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Product Name *",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        Obx(() {
          if (controller.isDropdownLoading.value) {
            return TextFormField(
              enabled: false,
              decoration: InputDecoration(
                hintText: "Loading products...",
                filled: true,
                fillColor: const Color(0xFFEDEDED),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.r),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          }

          return DropdownButtonFormField<String>(
            isExpanded: true,
            value: controller.selectedProduct.value.isEmpty
                ? null
                : controller.selectedProduct.value,
            items: controller.productDropdownList
                .map(
                  (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            selectedItemBuilder: (context) {
              return controller.productDropdownList.map((item) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            onChanged: (value) {
              if (value != null) {
                controller.selectedProduct.value = value;
              }
            },
            decoration: InputDecoration(
              hintText: "Select Product",
              filled: true,
              fillColor: const Color(0xFFEDEDED),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.r),
                borderSide: BorderSide(
                  color: Colors.orange.shade400,
                ),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
          );
        }),
      ],
    );
  }

  Widget _quantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quantity",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: controller.quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter quantity",
            filled: true,
            fillColor: const Color(0xFFEDEDED),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.r),
              borderSide: BorderSide(
                color: Colors.orange.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewProductQuantityTab extends GetView<ProductQuantityController> {
  const _ViewProductQuantityTab();

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "";
    }
    try {
      final DateTime parsed = DateTime.parse(date).toLocal();
      return DateFormat("dd-MMM-yyyy").format(parsed);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshList,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Quantity List",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 220.w,
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.searchProductQuantity,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Search",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Obx(() {
                    if (controller.isListLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.filteredList.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Text(
                            "No Product Quantity Found",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: constraints.maxHeight > 320
                          ? constraints.maxHeight - 80
                          : 420,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 40.w,
                              headingTextStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              dataTextStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              columns: const [
                                DataColumn(label: Text("S.no")),
                                DataColumn(label: Text("Product Name")),
                                DataColumn(label: Text("Quantity")),
                                DataColumn(label: Text("Create Date")),
                                DataColumn(label: Text("Update Date")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Action")),
                              ],
                              rows: List.generate(
                                controller.filteredList.length,
                                    (index) {
                                  final ProductQuantityData item =
                                  controller.filteredList[index];

                                  return DataRow(
                                    cells: [
                                      DataCell(Text("${index + 1}")),
                                      DataCell(
                                        SizedBox(
                                          width: 160.w,
                                          child: Text(
                                            item.productName ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text("${item.quantity ?? 0}")),
                                      DataCell(
                                        Text(formatDate(item.createDate)),
                                      ),
                                      DataCell(
                                        Text(formatDate(item.updateDate)),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (item.action ?? 0) == 1
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                            BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            (item.action ?? 0) == 1
                                                ? "Active"
                                                : "Inactive",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          onPressed: () {
                                            controller.openEditDialog(item);
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}