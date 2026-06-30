import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart' as session_model;

import '../controller/parent_id_controller.dart';

class ParentIdPage extends StatefulWidget {
  const ParentIdPage({super.key});

  @override
  State<ParentIdPage> createState() => _ParentIdPageState();
}

class _ParentIdPageState extends State<ParentIdPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ParentIdController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentIdController>();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ Listen to tabIndex change from controller and switch tab
    ever(controller.tabIndex, (index) {
      _tabController.animateTo(index);
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
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: const Text(
          "View Parents Id",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Search Parent id"),
            Tab(text: "View Parent id"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            _addTab(),
            _viewTab(),
          ],
        ),
      ),
    );
  }

  // =========================
  // ADD TAB: only filters + Search
  // =========================
  Widget _addTab() {
    return Column(
      children: [
        _filtersCard(),
        SizedBox(height: 12.h),
      ],
    );
  }

  // =========================
  // VIEW TAB: table only
  // =========================
  Widget _viewTab() {
    return Column(
      children: [
        Expanded(child: _tableCard()),
      ],
    );
  }

  // =========================
  // FILTER CARD
  // =========================
  Widget _filtersCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Student Parent Id",
            style:
            TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),

          // Row 1: Session + Class
          Row(
            children: [
              Expanded(child: _sessionDropdown()),
              SizedBox(width: 10.w),
              Expanded(child: _classDropdown()),
            ],
          ),

          SizedBox(height: 14.h),

          // Row 2: Section
          Row(
            children: [
              Expanded(child: _sectionDropdown()),
              SizedBox(width: 10.w),
              Expanded(child: SizedBox(height: 56.h)),
            ],
          ),

          SizedBox(height: 12.h),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.pink.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () => controller.searchParentIdList(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                      vertical: 12.h, horizontal: 16.w),
                ),
                child: const Text("Search",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SESSION DROPDOWN
  // =========================
  Widget _sessionDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 56.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return DropdownButtonFormField<session_model.sListDdata>(
        value: controller.selectedSession.value,
        isExpanded: true,
        hint: Text(
          "Select Session",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp),
        ),
        onChanged: (newVal) {
          controller.selectedSession.value = newVal;
          controller.session.value = newVal?.session ?? '';
        },
        items: controller.sessionList.map((s) {
          return DropdownMenuItem<session_model.sListDdata>(
            value: s,
            child: Text(
              s.session ?? "No session",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Session',
          labelStyle: TextStyle(fontSize: 20.sp),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide:
            BorderSide(color: Colors.teal.shade800, width: 1.2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      );
    });
  }

  // =========================
  // CLASS DROPDOWN
  // =========================
  Widget _classDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<ListDataa>(
        value: controller.selectedClass.value,
        hint: const Text("Select Class"),
        isExpanded: true,
        items: controller.listDataa.map((item) {
          return DropdownMenuItem<ListDataa>(
            value: item,
            child: Text(item.className ?? ""),
          );
        }).toList(),
        onChanged: (val) => controller.setSelectedClass(val),
        decoration: const InputDecoration(
          labelText: 'Class',
          labelStyle: TextStyle(color: Colors.teal),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      );
    });
  }

  // =========================
  // SECTION DROPDOWN
  // =========================
  Widget _sectionDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<ListDatta>(
        value: controller.selectedSection.value,
        hint: const Text(
          "Select Section",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        isExpanded: true,
        items: controller.sectionList.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item.section ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: controller.setSelectedSection,
        decoration: const InputDecoration(
          labelText: 'Section',
          labelStyle: TextStyle(color: Colors.teal),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      );
    });
  }

  // =========================
  // TABLE CARD (View tab)
  // =========================
  Widget _tableCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Parent Id List",
                  style: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Obx(() {
                final disabled =
                    controller.isLoading.value || controller.rows.isEmpty;
                return Row(
                  children: [
                    IconButton(
                      tooltip: "Share PDF",
                      onPressed: disabled
                          ? null
                          : () => controller.shareParentIdPdf(),
                      icon: const Icon(Icons.share),
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 10.h),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.rows.isEmpty) {
                return const Center(child: Text("No Data Found"));
              }

              return Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("S.No")),
                        DataColumn(label: Text("Registration No")),
                        DataColumn(label: Text("Student Name")),
                        DataColumn(label: Text("Father Name")),
                        DataColumn(label: Text("Class")),
                        DataColumn(label: Text("Section")),
                        DataColumn(label: Text("Mobile")),
                        DataColumn(label: Text("Parent Id")),
                        DataColumn(label: Text("Password")),
                      ],
                      rows: List.generate(controller.rows.length, (i) {
                        final r = controller.rows[i];
                        return DataRow(
                          cells: [
                            DataCell(Text("${i + 1}")),
                            DataCell(Text(r.registrationNo)),
                            DataCell(Text(r.studentName)),
                            DataCell(Text(r.fatherName)),
                            DataCell(Text(r.className)),
                            DataCell(Text(r.sectionName)),
                            DataCell(Text(r.phone)),
                            DataCell(Text(r.parentId)),
                            DataCell(Text(r.password)),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}