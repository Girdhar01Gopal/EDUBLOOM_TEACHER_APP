import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/routepointmaster_controller.dart';
import '../models/routeno.dart';
import '../models/route_point_model.dart';

class RoutePointMasterScreen extends StatelessWidget {
  const RoutePointMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RoutePointController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "📍 Route Point Master",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add_location_alt), text: "Add Route Point"),
              Tab(icon: Icon(Icons.view_list), text: "Route Point List"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddRoutePointTab(),
            _RoutePointListTab(),
          ],
        ),
      ),
    );
  }
}

// =======================
// ADD TAB (SAME)
// =======================
class _AddRoutePointTab extends GetView<RoutePointController> {
  const _AddRoutePointTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Route Point",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),

            DropdownButtonFormField<RouteData>(
              value: controller.selectedRoute.value,
              isExpanded: true,
              items: controller.routes.map((r) {
                return DropdownMenuItem<RouteData>(
                  value: r,
                  child: Text("Route ${r.routeNo} | Bus ${r.busNo}"),
                );
              }).toList(),
              onChanged: (val) => controller.selectedRoute.value = val,
              decoration: const InputDecoration(
                labelText: "Route No *",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 12.h),

            TextField(
              controller: controller.stoppageController,
              decoration: InputDecoration(
                hintText: "Enter stoppage name",
                labelText: "Stoppage / Pickup Point *",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Row(
              children: [
                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isPosting.value ? null : controller.addRoutePoint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// =======================
// LIST TAB (UPDATED: H + V SCROLL)
// =======================
class _RoutePointListTab extends GetView<RoutePointController> {
  const _RoutePointListTab();

  String _fmtDate(DateTime? dt) {
    if (dt == null) return "-";
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return "$d-$m-$y";
  }

  void _showEditDialog(RoutePoint item) {
    final stoppageCtrl = TextEditingController(text: item.pickupPoint);

    RouteData? selectedRoute;
    for (final r in controller.routes) {
      if (r.routeNo == item.routeNo) {
        selectedRoute = r;
        break;
      }
    }
    selectedRoute ??= controller.routes.isNotEmpty ? controller.routes.first : null;

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Route Point"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<RouteData>(
              value: selectedRoute,
              isExpanded: true,
              items: controller.routes.map((r) {
                return DropdownMenuItem<RouteData>(
                  value: r,
                  child: Text("Route ${r.routeNo} | Bus ${r.busNo}"),
                );
              }).toList(),
              onChanged: (val) => selectedRoute = val,
              decoration: const InputDecoration(
                labelText: "Route No *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stoppageCtrl,
              decoration: const InputDecoration(
                labelText: "Stoppage / Pickup Point *",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: controller.isPosting.value
                  ? null
                  : () {
                if (selectedRoute == null) {
                  Get.snackbar("Validation", "Please select route no");
                  return;
                }
                final pick = stoppageCtrl.text.trim();
                if (pick.isEmpty) {
                  Get.snackbar("Validation", "Please enter stoppage");
                  return;
                }

                controller.editRoutePoint(
                  routePointId: item.routePointId,
                  routeNo: selectedRoute!.routeNo,
                  pickupPoint: pick,
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
    return Obx(() {
      if (controller.isListLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.routePoints.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inbox_outlined, size: 50),
                SizedBox(height: 10.h),
                Text(
                  "No Route Points Found",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                ElevatedButton.icon(
                  onPressed: controller.fetchRoutePoints,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchRoutePoints(),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Route Point List",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: controller.fetchRoutePoints,
                      icon: const Icon(Icons.refresh),
                      tooltip: "Refresh",
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // ✅ UPDATED: Vertical + Horizontal scroll
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 44.h,
                          dataRowMinHeight: 44.h,
                          dataRowMaxHeight: 56.h,
                          columns: const [
                            DataColumn(label: Text("S.No")),
                            DataColumn(label: Text("Route No")),
                            DataColumn(label: Text("Stoppage")),
                            DataColumn(label: Text("Create Date")),
                            DataColumn(label: Text("Update Date")),
                            DataColumn(label: Text("Action")),
                          ],
                          rows: List.generate(controller.routePoints.length, (index) {
                            final item = controller.routePoints[index];

                            return DataRow(
                              cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(Text(item.routeNo.toString())),
                                DataCell(Text(item.pickupPoint)),
                                DataCell(Text(_fmtDate(item.createDate))),
                                DataCell(Text(_fmtDate(item.updateDate))),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _showEditDialog(item),
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
              ],
            ),
          ),
        ),
      );
    });
  }
}