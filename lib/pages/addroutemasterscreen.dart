import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/addroutemaster_controller.dart';

class RouteMasterScreen extends StatelessWidget {
  const RouteMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RouteMasterController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("🚌 Route Master", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Route"),
              Tab(icon: Icon(Icons.view_list), text: "View Route"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddRouteTab(),
            _RouteListTab(),
          ],
        ),
      ),
    );
  }
}

class _AddRouteTab extends GetView<RouteMasterController> {
  const _AddRouteTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Route",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),

          TextField(
            controller: controller.routeNoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Route No *",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12.h),

          TextField(
            controller: controller.busNoController,
            decoration: const InputDecoration(
              labelText: "Bus No *",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),

          Obx(() {
            return ElevatedButton(
              onPressed: controller.isPosting.value ? null : controller.addRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
              ),
              child: controller.isPosting.value
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text("Save", style: TextStyle(color: Colors.white)),
            );
          }),
        ],
      ),
    );
  }
}

class _RouteListTab extends GetView<RouteMasterController> {
  const _RouteListTab();

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd-MMM-yyyy");

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = controller.routeModel.value?.data ?? [];

      if (list.isEmpty) {
        return const Center(child: Text("No Route available"));
      }

      return Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Route List",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  onPressed: controller.fetchRoutes,
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
            SizedBox(height: 10.h),

            /// ✅ UPDATED: BOTH SCROLL (Vertical + Horizontal) + Scrollbar
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // ✅ vertical first
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // ✅ then horizontal
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 950.w),
                      child: DataTable(
                        headingRowHeight: 44.h,
                        dataRowMinHeight: 46.h,
                        dataRowMaxHeight: 60.h,
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Route No")),
                          DataColumn(label: Text("Bus No")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Update Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final item = list[i];

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(item.routeNo.toString())),
                              DataCell(Text(item.busNo)),
                              DataCell(Text(df.format(item.createDate))),
                              DataCell(
                                Text(
                                  item.updateDate == null ? "" : df.format(item.updateDate!),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () => controller.openEditDialog(item),
                                    ),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 22,
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
          ],
        ),
      );
    });
  }
}