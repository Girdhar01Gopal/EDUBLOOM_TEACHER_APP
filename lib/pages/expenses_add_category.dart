import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/expenses_add_category_controller.dart';

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);

class ExpensesCategoryScreen extends GetView<ExpensesCategoryController> {
  const ExpensesCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            "Expenses Categories",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: kAxisMaroon,
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
        ),
        body: const TabBarView(
          children: [
            _AddTab(),
            _ViewTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ADD TAB
// ─────────────────────────────────────────
class _AddTab extends GetView<ExpensesCategoryController> {
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
            const Text(
              "Add Expenses Category",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Category",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.categoryController,
              decoration: InputDecoration(
                hintText: "Enter Category Name",
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: kAxisMaroon),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Obx(
                  () => SizedBox(
                height: 42,
                width: 110,
                child: ElevatedButton(
                  onPressed: controller.isPosting.value
                      ? null
                      : controller.addCategory,
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
                        strokeWidth: 2, color: Colors.white),
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

// ─────────────────────────────────────────
// VIEW TAB
// ─────────────────────────────────────────
class _ViewTab extends GetView<ExpensesCategoryController> {
  const _ViewTab();

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return "$day-$month-$year";
  }

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
            const Text(
              "Add Expenses Category List",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),

            // Search bar
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 220,
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.searchCategory,
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Table (Horizontal + Vertical scroll)
            Obx(() {
              final list = controller.filteredStaticList;

              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No Categories Found")),
                );
              }

              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                      columnSpacing: 20,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 56,
                      columns: const [
                        DataColumn(
                            label: Text("S.no", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(
                            label: Text("Category Name", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(
                            label: Text("Create Date", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(
                            label: Text("Update Date", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(
                            label: Text("Action", style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                      rows: List.generate(list.length, (index) {
                        final item = list[index];

                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(
                            SizedBox(
                              width: 130,
                              child: Text(item.category!, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          DataCell(Text(formatDate(item.createDate))),
                          DataCell(Text(formatDate(item.updateDate))),

                          // Action — only Edit button (orange)
                          DataCell(
                            Row(
                              children: [
                                // Edit Button
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                                    onPressed: () => controller.openEditDialog(index),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Green Tick icon for action 1
                                if (item.action == '1') ...[
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ]);
                      }),
                    ),
                  ));
            }),
          ],
        ),
      ),
    );
  }
}