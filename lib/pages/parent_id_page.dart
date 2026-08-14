import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart' as session_model;

import '../controller/parent_id_controller.dart';

const Color axisMaroon = Color(0xFF97144D);

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
        backgroundColor: axisMaroon,
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              controller: controller.searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "Search by name, father, phone...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (value) => controller.updateSearchQuery(value),
            );
          }
          return const Text(
            "View Parents Id",
            style: TextStyle(color: Colors.white),
          );
        }),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isSearching.value ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () => controller.toggleSearch(),
          )),
        ],
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
  // ADD TAB: filters
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
  // VIEW TAB: table
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
              color: Colors.grey.withOpacity(0.2),
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

          Row(
            children: [
              Expanded(child: _sessionDropdown()),
              SizedBox(width: 10.w),
              Expanded(child: _classDropdown()),
            ],
          ),

          SizedBox(height: 14.h),

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
                gradient: const LinearGradient(
                  colors: [Color(0xFFAB1A5E), Color(0xFF97144D)],
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
        hint: const Text("Select Session"),
        onChanged: (newVal) {
          controller.selectedSession.value = newVal;
          controller.session.value = newVal?.session ?? '';
        },
        items: controller.sessionList.map((s) {
          return DropdownMenuItem<session_model.sListDdata>(
            value: s,
            child: Text(s.session ?? "No session"),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Session',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: Colors.white,
        ),
      );
    });
  }

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
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      );
    });
  }

  Widget _sectionDropdown() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return DropdownButtonFormField<ListDatta>(
        value: controller.selectedSection.value,
        hint: const Text("Select Section"),
        isExpanded: true,
        items: controller.sectionList.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.section ?? ""),
          );
        }).toList(),
        onChanged: controller.setSelectedSection,
        decoration: const InputDecoration(
          labelText: 'Section',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      );
    });
  }

  Widget _tableCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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

              // 🔍 Filtered rows ka use kiya hai
              final filteredList = controller.filteredRows;

              if (filteredList.isEmpty) {
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
                      rows: List.generate(filteredList.length, (i) {
                        final r = filteredList[i];
                        return DataRow(
                          cells: [
                            DataCell(Text("${i + 1}")),
                            DataCell(Text(r.registrationNo)),
                            DataCell(Text(r.studentName)),
                            DataCell(Text(r.fatherName)),
                            DataCell(Text(r.className)),
                            DataCell(Text(r.sectionName)),
                            DataCell(Text(r.phone)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(r.parentId),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: r.parentId));
                                      Get.snackbar("Copied", "Parent ID Copied", snackPosition: SnackPosition.BOTTOM);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(r.password),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: r.password));
                                      Get.snackbar("Copied", "Password Copied", snackPosition: SnackPosition.BOTTOM);
                                    },
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
              );
            }),
          ),
        ],
      ),
    );
  }
}