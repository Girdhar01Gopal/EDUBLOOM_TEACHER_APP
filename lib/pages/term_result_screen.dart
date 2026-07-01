import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/term_result_controller.dart';

class TermResultScreen extends StatelessWidget {
  const TermResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F1F1),
        appBar: AppBar(
          title: const Text(
            "Terms Result",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF99144E),
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
            _AddTermTab(),
            _TermListTab(),
          ],
        ),
      ),
    );
  }
}

class _AddTermTab extends GetView<TermResultController> {
  const _AddTermTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Term Result",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: controller.termController,
                    decoration: InputDecoration(
                      hintText: "Enter Term",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: const BorderSide(color: Color(0xFF99144E)),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Obx(() {
                    return SizedBox(
                      width: 130.w,
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: controller.isPosting.value
                            ? null
                            : controller.addTerm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4A300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
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
                            fontSize: 16.sp,
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
          ),
        ],
      ),
    );
  }
}

class _TermListTab extends GetView<TermResultController> {
  const _TermListTab();

  @override
  Widget build(BuildContext context) {
    final DateFormat df = DateFormat("dd-MMM-yyyy");

    return Obx(() {
      final list = controller.filteredList;

      return Padding(
        padding: EdgeInsets.all(14.r),
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Term Result List",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.isListLoading.value
                        ? null
                        : controller.refreshList,
                    icon: controller.isListLoading.value
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 220.w,
                  child: TextField(
                    onChanged: controller.searchTerm,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
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
              SizedBox(height: 12.h),
              Expanded(
                child: controller.isListLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                    ? RefreshIndicator(
                  onRefresh: controller.refreshList,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Center(child: Text("No Term Result available")),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: controller.refreshList,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 900.w),
                          child: DataTable(
                            headingRowColor:
                            WidgetStateProperty.all(
                              Colors.grey.shade100,
                            ),
                            dataRowColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            columnSpacing: 28.w,
                            columns: const [
                              DataColumn(label: Text("S.no")),
                              DataColumn(label: Text("Term")),
                              DataColumn(label: Text("Create Date")),
                              DataColumn(label: Text("Update Date")),
                              DataColumn(label: Text("Action")),
                            ],
                            rows: List.generate(list.length, (index) {
                              final item = list[index];
                              final bool isActive =
                                  (item.action ?? "") == "1";

                              return DataRow(
                                cells: [
                                  DataCell(Text("${index + 1}")),
                                  DataCell(
                                    SizedBox(
                                      width: 180.w,
                                      child: Text(
                                        item.term ?? "",
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      item.createDate == null
                                          ? ""
                                          : df.format(
                                        item.createDate!,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      item.updateDate == null
                                          ? ""
                                          : df.format(
                                        item.updateDate!,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => controller
                                              .openEditTermDialog(
                                            item,
                                          ),
                                          child: Container(
                                            padding:
                                            const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  4),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                          const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.green
                                                : Colors.grey,
                                            borderRadius:
                                            BorderRadius.circular(
                                                4),
                                          ),
                                          child: Icon(
                                            isActive
                                                ? Icons.check
                                                : Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}