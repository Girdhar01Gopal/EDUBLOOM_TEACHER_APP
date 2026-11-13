import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/product_quantity_controller.dart';
import '../models/product_quantity_model.dart';
import '../wigets/active_inactive_chip.dart';

/// ---------------- Common helpers (repeat hone wala code) ----------------

EdgeInsets get _pagePadding =>
    EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);

BoxDecoration get _cardDecoration => BoxDecoration(
  color: const Color(0xFFF8F8F8),
  borderRadius: BorderRadius.circular(4.r),
);

TextStyle get _titleStyle => TextStyle(
  fontSize: 18.sp,
  fontWeight: FontWeight.w700,
  color: Colors.black,
);

Widget _fieldLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14.sp,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
  );
}

InputDecoration _fieldDecoration({
  required String hint,
  bool withFocusBorder = true,
}) {
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(3.r),
    borderSide: BorderSide.none,
  );

  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFEDEDED),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 14.w,
      vertical: 14.h,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: withFocusBorder
        ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.r),
      borderSide: BorderSide(
        color: Colors.orange.shade400,
      ),
    )
        : null,
  );
}

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
          backgroundColor: const Color(0xFF97134D),
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
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.r),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Product Quantity", style: _titleStyle),
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
                  final bool posting = controller.isPosting.value;

                  return SizedBox(
                    width: 115.w,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: posting ? null : controller.addProductQuantity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5AC00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        elevation: 0,
                      ),
                      child: posting
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
        _fieldLabel("Select Product Name *"),
        SizedBox(height: 10.h),
        Obx(() {
          if (controller.isDropdownLoading.value) {
            return TextFormField(
              enabled: false,
              decoration: _fieldDecoration(
                hint: "Loading products...",
                withFocusBorder: false,
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
            decoration: _fieldDecoration(hint: "Select Product"),
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
        _fieldLabel("Quantity"),
        SizedBox(height: 10.h),
        TextField(
          controller: controller.quantityController,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration(hint: "Enter quantity"),
        ),
      ],
    );
  }
}

class _ViewProductQuantityTab extends GetView<ProductQuantityController> {
  const _ViewProductQuantityTab();

  static const List<DataColumn> _columns = [
    DataColumn(label: Text("S.no")),
    DataColumn(label: Text("Product Name")),
    DataColumn(label: Text("Quantity")),
    DataColumn(label: Text("Create Date")),
    DataColumn(label: Text("Update Date")),
    DataColumn(label: Text("Status")),
    DataColumn(label: Text("Action")),
  ];

  /// DateFormat ek hi baar banta hai (har row/har call pe nahi)
  static final DateFormat _dateFormat = DateFormat("dd-MMM-yyyy");

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "";
    }
    try {
      final DateTime parsed = DateTime.parse(date).toLocal();
      return _dateFormat.format(parsed);
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
            padding: _pagePadding,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.r),
              decoration: _cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Product Quantity List", style: _titleStyle),
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

                    final list = controller.filteredList;

                    if (list.isEmpty) {
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
                              columns: _columns,
                              rows: List.generate(
                                list.length,
                                    (index) {
                                  final ProductQuantityData item = list[index];
                                  final bool isActive = (item.action ?? 0) == 1;

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
                                        GestureDetector(
                                          onTap: () =>
                                              showActiveInactiveApiPending(
                                                  "Product Quantity"),
                                          child: Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              borderRadius:
                                              BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isActive ? "Active" : "Inactive",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
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