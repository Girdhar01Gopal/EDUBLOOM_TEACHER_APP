import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_products_controller.dart';

const Color _primaryColor = Color(0xFF97134D);
const Color _fieldFillColor = Color(0xFFF1F1F1);

const TextStyle _titleStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w700,
);

const TextStyle _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

/// Common input decoration (Add tab ke dono fields ke liye)
InputDecoration _fieldDecoration(String hint) {
  const borderRadius = BorderRadius.all(Radius.circular(4));
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: _fieldFillColor,
    border: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: _primaryColor),
    ),
  );
}

class AddProductsScreen extends GetView<AddProductsController> {
  const AddProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: _ProductsAppBar(),
        body: TabBarView(
          children: [
            _AddTab(),
            _ViewTab(),
          ],
        ),
      ),
    );
  }
}

class _ProductsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProductsAppBar();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "Add Products",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: _primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: const TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: [
          Tab(text: "Add"),
          Tab(text: "View"),
        ],
      ),
    );
  }
}

class _AddTab extends GetView<AddProductsController> {
  const _AddTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Product", style: _titleStyle),
            const SizedBox(height: 16),
            const Text("Product Name", style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: controller.productController,
              decoration: _fieldDecoration("Enter Product Name"),
            ),
            const SizedBox(height: 16),
            const Text("Amount", style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: controller.amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: _fieldDecoration("Enter Amount"),
            ),
            const SizedBox(height: 22),
            Obx(
                  () => SizedBox(
                height: 42,
                width: 110,
                child: ElevatedButton(
                  onPressed:
                  controller.isPosting.value ? null : controller.addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: controller.isPosting.value
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewTab extends GetView<AddProductsController> {
  const _ViewTab();

  static const List<DataColumn> _columns = [
    DataColumn(label: Text("S.No")),
    DataColumn(label: Text("Product")),
    DataColumn(label: Text("Amount")),
    DataColumn(label: Text("Update Date")),
    DataColumn(label: Text("Create Date")),
    DataColumn(label: Text("Status")),
    DataColumn(label: Text("Action")),
  ];

  String formatDate(DateTime? date) {
    if (date == null) return "";
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return "$day-$month-$year";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshList,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("View Products", style: _titleStyle),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 220,
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.searchProduct,
                        decoration: InputDecoration(
                          hintText: "Search",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// only loading section wrapped
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
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text("No Product Found"),
                        ),
                      );
                    }

                    return SizedBox(
                      height: constraints.maxHeight > 300
                          ? constraints.maxHeight - 80
                          : 400,
                      child: Scrollbar(
                        controller: controller.productsScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: controller.productsScrollController,
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey.shade200,
                              ),
                              columnSpacing: 26,
                              columns: _columns,
                              rows: List.generate(
                                list.length,
                                    (index) {
                                  final item = list[index];

                                  return DataRow(
                                    cells: [
                                      DataCell(Text("${index + 1}")),
                                      DataCell(
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            item.product,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(item.pAmount.toString())),
                                      DataCell(
                                        Text(formatDate(item.updateDate)),
                                      ),
                                      DataCell(
                                        Text(formatDate(item.createDate)),
                                      ),
                                      DataCell(
                                        Obx(() {
                                          final busy = controller
                                              .statusLoadingId.value ==
                                              item.pmasterId;
                                          if (busy) {
                                            return const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            );
                                          }
                                          final isActive = item.action == 1;
                                          return GestureDetector(
                                            onTap: () => controller
                                                .toggleProductStatus(item),
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
                                                isActive
                                                    ? "Active"
                                                    : "Inactive",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      DataCell(
                                        IconButton(
                                          onPressed: () {
                                            controller
                                                .openEditProductDialog(item);
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