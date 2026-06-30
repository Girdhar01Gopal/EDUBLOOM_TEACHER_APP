import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/AddResultController.dart';
import '../models/classmodel.dart';
import '../models/subject_model.dart';
import '../models/terms_result_model.dart';

class AddResultMasterScreen extends StatefulWidget {
  const AddResultMasterScreen({super.key});

  @override
  State<AddResultMasterScreen> createState() => _AddResultMasterScreenState();
}

class _AddResultMasterScreenState extends State<AddResultMasterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AddResultController controller = Get.find<AddResultController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    ever(controller.currentTab, (int index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Add Result",
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
          onTap: (i) => controller.currentTab.value = i,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: "Search"),
            Tab(icon: Icon(Icons.view_list), text: "View"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _SearchTab(),
          _ViewTab(),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================
InputDecoration _fieldDec(String label) => InputDecoration(
  labelText: "$label *",
  border: const OutlineInputBorder(),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey.shade300),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.teal.shade800),
  ),
  isDense: true,
  filled: true,
  fillColor: Colors.white,
  contentPadding:
  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
);

Widget _ellipsis(String t) => Text(
  t,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  softWrap: false,
);

// ============================================================
// SEARCH TAB
// ============================================================
class _SearchTab extends GetView<AddResultController> {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Search Students",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── Row 1: Class + Subject ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _classDropdown()),
                      SizedBox(width: 12.w),
                      Expanded(child: _subjectDropdown()),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ── Row 2: Section + Term ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _sectionDropdown()),
                      SizedBox(width: 12.w),
                      Expanded(child: _termDropdown()),
                    ],
                  ),
                  SizedBox(height: 22.h),

                  // ── Save Button ──
                  Obx(() => SizedBox(
                    width: 130.w,
                    height: 46.h,
                    child: ElevatedButton.icon(
                      onPressed: controller.isSearching.value
                          ? null
                          : controller.searchStudents,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isSearching.value
                            ? Colors.grey
                            : Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: controller.isSearching.value
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.search,
                          color: Colors.white, size: 18),
                      label: Text(
                        controller.isSearching.value ? "Saving..." : "Save",
                        style: const TextStyle(
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

          // ── Page loader ──
          if (controller.isPageLoading.value)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _classDropdown() {
    return Obx(() => DropdownButtonFormField<ListDataa>(
      value: controller.selectedClass.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Class"),
      decoration: _fieldDec("Class"),
      items: controller.classList
          .map((c) => DropdownMenuItem<ListDataa>(
        value: c,
        child: _ellipsis(c.className ?? ""),
      ))
          .toList(),
      onChanged: (v) => controller.selectedClass.value = v,
    ));
  }

  Widget _subjectDropdown() {
    return Obx(() => DropdownButtonFormField<ListDaataa>(
      value: controller.selectedSubject.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Subject"),
      decoration: _fieldDec("Subject"),
      items: controller.subjectList
          .map((s) => DropdownMenuItem<ListDaataa>(
        value: s,
        child: _ellipsis((s.subject ?? "-").toString()),
      ))
          .toList(),
      onChanged: (v) => controller.selectedSubject.value = v,
    ));
  }

  Widget _sectionDropdown() {
    return Obx(() => DropdownButtonFormField<dynamic>(
      value: controller.selectedSection.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Section"),
      decoration: _fieldDec("Section"),
      items: controller.sectionList
          .map((s) => DropdownMenuItem<dynamic>(
        value: s,
        child: _ellipsis((s.section ?? "").toString()),
      ))
          .toList(),
      onChanged: (v) => controller.selectedSection.value = v,
    ));
  }

  Widget _termDropdown() {
    return Obx(() => DropdownButtonFormField<TermData>(
      value: controller.selectedTerm.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Term"),
      decoration: _fieldDec("Term"),
      items: controller.termList
          .map((t) => DropdownMenuItem<TermData>(
        value: t,
        child: _ellipsis(t.term ?? ""),
      ))
          .toList(),
      onChanged: (v) => controller.selectedTerm.value = v,
    ));
  }
}

// ============================================================
// VIEW TAB
// ============================================================
class _ViewTab extends GetView<AddResultController> {
  const _ViewTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.studentList;
      final bool isLoading = controller.isSearching.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Search Bar (only when list has data) ──
          if (list.isNotEmpty) _SearchBar(controller: controller),

          // ── Body ──
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                ? _EmptyState()
                : _CardListWithSubmit(controller: controller),
          ),
        ],
      );
    });
  }
}

// ── Search Bar ──────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final AddResultController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val.trim(),
        decoration: InputDecoration(
          hintText: "Search by name or reg. no...",
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              controller.searchQuery.value = "";
              FocusScope.of(context).unfocus();
            },
          )
              : const SizedBox.shrink()),
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_search, size: 52, color: Colors.grey.shade300),
          SizedBox(height: 14.h),
          Text(
            "No students loaded yet.\nSelect filters and press Save.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card List + Submit Button ────────────────────────────────
class _CardListWithSubmit extends StatelessWidget {
  final AddResultController controller;
  const _CardListWithSubmit({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Card list ──
        Expanded(
          child: Obx(() {
            final query = controller.searchQuery.value.toLowerCase();
            final filtered = query.isEmpty
                ? controller.studentList
                : controller.studentList.where((s) {
              return s.studentName.toLowerCase().contains(query) ||
                  s.registrationNo.toLowerCase().contains(query);
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  "No match found.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final gradeRx = controller.gradeMap[item.studentId];
                final originalIndex =
                    controller.studentList.indexOf(item) + 1;

                return _StudentCard(
                  item: item,
                  index: originalIndex,
                  gradeRx: gradeRx,
                  gradeOptions: controller.gradeOptions,
                );
              },
            );
          }),
        ),

        // ── Submit Button ──
        Obx(() {
          if (controller.studentList.isEmpty) return const SizedBox.shrink();
          return Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.submitGrades,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isSubmitting.value
                      ? Colors.grey
                      : Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 1,
                ),
                icon: controller.isSubmitting.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 20),
                label: Text(
                  controller.isSubmitting.value ? "Submitting..." : "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Individual Student Card ──────────────────────────────────
class _StudentCard extends StatelessWidget {
  final dynamic item;
  final int index;
  final RxString? gradeRx;
  final List<String> gradeOptions;

  const _StudentCard({
    required this.item,
    required this.index,
    required this.gradeRx,
    required this.gradeOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ FIX
        children: [
          // ── Card Header ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.teal.shade800,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$index",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ FIX
                    children: [
                      Text(
                        item.studentName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Reg: ${item.registrationNo}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (gradeRx != null)
                  Obx(() => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _gradeColor(gradeRx!.value),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      gradeRx!.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                  )),
              ],
            ),
          ),

          // ── Card Body ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ FIX
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Father name + Class
                Row(
                  children: [
                    _infoTile(
                      icon: Icons.person_outline,
                      label: "Father",
                      value: item.fatherName,
                    ),
                    SizedBox(width: 12.w),
                    _infoTile(
                      icon: Icons.class_outlined,
                      label: "Class",
                      value: item.className,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Row 2: Section + Term
                Row(
                  children: [
                    _infoTile(
                      icon: Icons.group_outlined,
                      label: "Section",
                      value: item.section ?? "-",
                    ),
                    SizedBox(width: 12.w),
                    _infoTile(
                      icon: Icons.calendar_today_outlined,
                      label: "Term",
                      value: item.term,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Row 3: Subject (full width)
                Row(
                  children: [
                    _infoTile(
                      icon: Icons.menu_book_outlined,
                      label: "Subject",
                      value: item.subject,
                      fullWidth: true,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // ── Grade Selector ──
                if (gradeRx != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ FIX
                    children: [
                      Divider(color: Colors.grey.shade100, height: 1),
                      SizedBox(height: 10.h),
                      Text(
                        "Select Grade",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(() => Row(
                        children: gradeOptions.map((g) {
                          final isSelected = gradeRx!.value == g;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () => gradeRx!.value = g,
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 180),
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _gradeColor(g)
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? _gradeColor(g)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: mainAxisSize.min added
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 2 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: Colors.teal.shade700),
          SizedBox(width: 4.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ KEY FIX
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case "A":
        return Colors.green.shade600;
      case "B":
        return Colors.teal.shade600;
      case "C":
        return Colors.blue.shade600;
      case "D":
        return Colors.orange.shade600;
      case "E":
        return Colors.deepOrange.shade600;
      case "F":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}