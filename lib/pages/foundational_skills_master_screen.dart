import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/foundational_skills_controller.dart';

class FoundationalSkillsMasterScreen extends StatefulWidget {
  const FoundationalSkillsMasterScreen({super.key});

  @override
  State<FoundationalSkillsMasterScreen> createState() =>
      _FoundationalSkillsMasterScreenState();
}

class _FoundationalSkillsMasterScreenState
    extends State<FoundationalSkillsMasterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FoundationalSkillsController controller =
  Get.find<FoundationalSkillsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ Auto-refresh list every time View tab is opened
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _tabController.index == 1) {
        controller.refreshList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text(
          "Foundational Skills",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: "Add"),
            Tab(icon: Icon(Icons.view_list), text: "View"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AddFoundationalSkillsTab(),
          _FoundationalSkillsListTab(),
        ],
      ),
    );
  }
}

// =============================================================
// ADD TAB
// =============================================================
class _AddFoundationalSkillsTab
    extends GetView<FoundationalSkillsController> {
  const _AddFoundationalSkillsTab();

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
                    "Foundational Skills",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: controller.foundationalSkillsController,
                    decoration: InputDecoration(
                      hintText: "Enter Foundational Skills",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide:
                        BorderSide(color: Colors.teal.shade700),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Obx(() => SizedBox(
                    width: 130.w,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: controller.isPosting.value
                          ? null
                          : controller.addFoundationalSkill,
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
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// VIEW / LIST TAB
// =============================================================
class _FoundationalSkillsListTab
    extends GetView<FoundationalSkillsController> {
  const _FoundationalSkillsListTab();

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd-MMM-yyyy");

    return Obx(() {
      // ✅ Full-screen loader on initial fetch
      if (controller.isListLoading.value &&
          controller.filteredList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

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
                  offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Foundational Skills List",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ✅ Manual refresh button with live loader indicator
                  Obx(() => controller.isListLoading.value
                      ? SizedBox(
                    height: 24.r,
                    width: 24.r,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2),
                  )
                      : IconButton(
                    onPressed: controller.refreshList,
                    icon: const Icon(Icons.refresh),
                    tooltip: "Refresh",
                  )),
                ],
              ),

              SizedBox(height: 14.h),

              // ── Search ──
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 220.w,
                  child: TextField(
                    onChanged: controller.searchFoundationalSkill,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search",
                      prefixIcon:
                      const Icon(Icons.search, size: 18),
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

              // ── Table ──
              Expanded(
                child: list.isEmpty
                    ? const Center(
                  child: Text("No Foundational Skills available"),
                )
                    : RefreshIndicator(
                  // ✅ Pull-to-refresh
                  onRefresh: controller.refreshList,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minWidth: 900.w),
                          child: DataTable(
                            headingRowColor:
                            WidgetStateProperty.all(
                                Colors.grey.shade100),
                            dataRowColor:
                            WidgetStateProperty.all(
                                Colors.white),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            columnSpacing: 28.w,
                            columns: const [
                              DataColumn(label: Text("S.no")),
                              DataColumn(
                                  label: Text(
                                      "Foundational Skills")),
                              DataColumn(
                                  label: Text("Create Date")),
                              DataColumn(
                                  label: Text("Update Date")),
                              DataColumn(
                                  label: Text("Action")),
                            ],
                            rows: List.generate(
                              list.length,
                                  (index) {
                                final item = list[index];
                                return DataRow(cells: [
                                  DataCell(
                                      Text("${index + 1}")),
                                  DataCell(
                                    SizedBox(
                                      width: 180.w,
                                      child: Text(
                                        item.foundationalSkills,
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(
                                      df.format(item.createDate))),
                                  DataCell(Text(
                                    item.updateDate == null
                                        ? ""
                                        : df.format(
                                        item.updateDate!),
                                  )),
                                  DataCell(
                                    Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        // Edit button
                                        InkWell(
                                          onTap: () => controller
                                              .openEditFoundationalSkillDialog(
                                              item),
                                          child: Container(
                                            padding:
                                            const EdgeInsets
                                                .all(6),
                                            decoration:
                                            BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Status button
                                        Container(
                                          padding:
                                          const EdgeInsets
                                              .all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              },
                            ),
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