import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/behaviourcontroller.dart';


const Color axisMaroon = Color(0xFF97144D);
const Color axisMaroonShade50 = Color(0xFFF3E0E9);
const Color axisMaroonShade300 = Color(0xFFC0568C);
const Color axisMaroonShade700 = Color(0xFF97144D);
const Color axisMaroonShade800 = Color(0xFF800F40);

class Behaviourview extends GetView<Behaviourcontroller> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: axisMaroonShade800,
          title: Text(
            "Behaviour Activity",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "Add Behaviour"),
              Tab(text: "View Behaviour"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostActivity(),
            ViewActivityScreen(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
//  ADD BEHAVIOUR ACTIVITY TAB
// ══════════════════════════════════════
class PostActivity extends GetView<Behaviourcontroller> {
  const PostActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),

          // ── Header card ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [axisMaroonShade800, axisMaroonShade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 26.r),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Post New Behaviour",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Fill details to record student behaviour",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ── Form card ──
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _sectionLabel("Student Type", Icons.category_rounded),
                SizedBox(height: 8.h),
                _typeDropdown(controller),

                SizedBox(height: 16.h),


                Obx(() {
                  if (controller.selecttype.value != "Pre School") {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _multiSelectHeader(
                        "Select Class (Multiple)",
                        Icons.class_rounded,
                        onSelectAll: () {
                          for (final c in controller.listDataa) {
                            if (!controller.selectedClasses
                                .any((s) => s.classId == c.classId)) {
                              controller.toggleClassSelection(c);
                            }
                          }
                        },
                        onClear: () {
                          controller.clearSelectedClasses();
                        },
                      ),
                      SizedBox(height: 8.h),
                      _classMultiSelect(controller),
                      SizedBox(height: 16.h),
                    ],
                  );
                }),

                _sectionLabel("Select Students", Icons.people_rounded),
                SizedBox(height: 8.h),
                _studentSelector(controller),

                SizedBox(height: 16.h),
                _sectionLabel("Behaviour Description", Icons.edit_note_rounded),
                SizedBox(height: 8.h),
                _activityField(controller),

                SizedBox(height: 16.h),
                _sectionLabel("Time Slot", Icons.access_time_rounded),
                SizedBox(height: 8.h),
                _timeRow(controller),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ── Submit button ──
          _submitButton(controller),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

// ── Section label helper ──
Widget _sectionLabel(String label, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 16, color: axisMaroonShade700),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
}

// ── Section label + "Select all" / "Clear" header (mirrors the
// NotificationScreen's _multiSelectHeader pattern) ──
Widget _multiSelectHeader(
    String label,
    IconData icon, {
      required VoidCallback onSelectAll,
      required VoidCallback onClear,
    }) {
  return Row(
    children: [
      Expanded(child: _sectionLabel(label, icon)),
      GestureDetector(
        onTap: onSelectAll,
        child: Text(
          "Select all",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: axisMaroonShade700,
          ),
        ),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: onClear,
        child: Text(
          "Clear",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════
//  VIEW BEHAVIOUR ACTIVITY TAB
// ══════════════════════════════════════
class ViewActivityScreen extends GetView<Behaviourcontroller> {
  String _formatTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "";
    final s = raw.trim();
    final already = RegExp(r'^\d{1,2}:\d{2}\s?(AM|PM|am|pm)$');
    if (already.hasMatch(s)) {
      final parts = s.split(RegExp(r'\s+'));
      if (parts.length == 2) return "${parts[0]} ${parts[1].toUpperCase()}";
      return s.toUpperCase();
    }
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      int hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return "${hour.toString().padLeft(2, '0')}:$minute $ampm";
    }
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s);
    if (m != null) {
      int hour = int.parse(m.group(1)!);
      final minute = m.group(2)!;
      final ampm = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return "${hour.toString().padLeft(2, '0')}:$minute $ampm";
    }
    final m2 = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})$').firstMatch(s);
    if (m2 != null) {
      int hour = int.parse(m2.group(1)!);
      final minute = m2.group(2)!;
      final ampm = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return "${hour.toString().padLeft(2, '0')}:$minute $ampm";
    }
    return s;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "";
    final s = raw.trim();
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    }
    final parts = s.replaceAll('/', '-').split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return "${parts[2].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[0]}";
      }
      if (parts[2].length == 4) {
        return "${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[2]}";
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── search bar — filters by student name, class, date, or
        // the behaviour text (the card heading). ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: "Search by name, class, date or text...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
              prefixIcon: Icon(Icons.search_rounded, color: axisMaroonShade700),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: axisMaroonShade700, width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.filteredActivityList;

            if (controller.activityList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      "No Activities Found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      "No matching activities",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final act = list[index];
                final from = _formatTime(act.fromTime);
                final to = _formatTime(act.toTime);
                final date = _formatDate(act.createDate);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade100.withOpacity(0.7),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ── Gradient header ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.shade400,
                              Colors.pink.shade200,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.psychology_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                act.behaviour ?? "No Activity",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "#${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Info rows ──
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Column(
                          children: [
                            _infoRow(
                              icon: Icons.person_rounded,
                              iconColor: Colors.pink.shade300,
                              label: "Student",
                              value: act.studentName ?? "N/A",
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRowCompact(
                                    icon: Icons.play_circle_outline_rounded,
                                    iconColor: axisMaroon,
                                    label: "From",
                                    value: from.isEmpty ? "N/A" : from,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _infoRowCompact(
                                    icon: Icons.stop_circle_outlined,
                                    iconColor: Colors.orange,
                                    label: "To",
                                    value: to.isEmpty ? "N/A" : to,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _infoRow(
                              icon: Icons.calendar_today_rounded,
                              iconColor: Colors.blue,
                              label: "Date",
                              value: date.isEmpty ? "N/A" : date,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _infoRowCompact({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════

// ── Student Type dropdown (Day Care / Pre School) — mirrors the
// Meal screen's _typeDropdown. onChanged routes through
// controller.onTypeChanged() which resets selections and fetches the
// correct student list (Day Care API vs Pre School API). ──
Widget _typeDropdown(Behaviourcontroller controller) {
  return Obx(() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: "Select student type",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: axisMaroonShade700, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      value: controller.selecttype.value.isEmpty
          ? null
          : controller.selecttype.value,
      items: ["Day Care", "Pre School"]
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        controller.onTypeChanged(value);
      },
    );
  });
}

// 🆕 CHANGED: Class multi-select is now a horizontal scrollable chip
// row — EXACTLY like NotificationScreen's _classMultiSelect — instead
// of a wrapped FilterChip grid. Reads from
// Behaviourcontroller.listDataa (populated by the 3-way API flow:
// Staff -> ViewClass API, Class Teacher -> ClassTeacher API, Normal
// Teacher -> GetClassTeacher API, with staff fallback) and
// Behaviourcontroller.selectedClasses. Only rendered when Pre School
// is selected — see the Obx gate in PostActivity above.
Widget _classMultiSelect(Behaviourcontroller controller) {
  return SizedBox(
    height: 42.h,
    child: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.listDataa.isEmpty) {
        return Text(
          "No classes found",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        );
      }
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.listDataa.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cls = controller.listDataa[index];
          return Obx(() {
            final isSelected = controller.selectedClasses
                .any((c) => c.classId == cls.classId);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.toggleClassSelection(cls),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? axisMaroon : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? axisMaroon : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_circle,
                          size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      cls.className ?? "",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    }),
  );
}

Widget _studentSelector(Behaviourcontroller controller) {
  return Obx(() {
    return InkWell(
      onTap: () => _openStudentSelector(controller),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.selectedStudent.isEmpty
                    ? "Choose students"
                    : controller.selectedStudent
                    .map((e) => e.studentName)
                    .join(", "),
                style: TextStyle(
                  fontSize: 13,
                  color: controller.selectedStudent.isEmpty
                      ? Colors.grey.shade500
                      : Colors.black87,
                  fontWeight: controller.selectedStudent.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.people_rounded, size: 18, color: axisMaroonShade700),
          ],
        ),
      ),
    );
  });
}

void _openStudentSelector(Behaviourcontroller controller) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Select Students",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              // ── "Select all" / "Clear" for students ──
              GestureDetector(
                onTap: () {
                  for (final student in controller.studentList) {
                    if (!controller.selectedStudentIds
                        .contains(student.studentId)) {
                      controller.selectedStudent.add(student);
                      controller.selectedStudentIds.add(student.studentId!);
                    }
                  }
                },
                child: Text(
                  "Select all",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: axisMaroonShade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  controller.selectedStudent.clear();
                  controller.selectedStudentIds.clear();
                },
                child: Text(
                  "Clear",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.studentList.isEmpty) {
                return Center(
                  child: Text(
                    "No students available",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.studentList.length,
                itemBuilder: (_, index) {
                  final student = controller.studentList[index];
                  return Obx(() {
                    final isSelected = controller.selectedStudentIds
                        .contains(student.studentId);
                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: axisMaroon,
                      title: Text(student.studentName ?? "Unnamed"),
                      onChanged: (checked) {
                        if (checked == true) {
                          if (!controller.selectedStudentIds
                              .contains(student.studentId)) {
                            controller.selectedStudent.add(student);
                            controller.selectedStudentIds
                                .add(student.studentId!);
                          }
                        } else {
                          controller.selectedStudent.remove(student);
                          controller.selectedStudentIds
                              .remove(student.studentId);
                        }
                      },
                    );
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: axisMaroonShade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _timeRow(Behaviourcontroller controller) {
  return Row(
    children: [
      Expanded(
        child: _timeBox("From Time", controller.fromTime, () {
          controller.pickTime(controller.fromTime);
        }),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _timeBox("To Time", controller.toTime, () {
          controller.pickTime(controller.toTime);
        }),
      ),
    ],
  );
}

Widget _submitButton(Behaviourcontroller controller) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: () async {
        // ✅ Same validation style as Meal — block if no student
        // selected before hitting the API.
        if (controller.selectedStudentIds.isEmpty) {
          Get.snackbar(
            "Validation",
            "Please select a student first.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          );
          return;
        }

        final success =
        await controller.postActivityToApi(controller.selectedStudentIds);
        if (success) {
          // ── Success snackbar: solid green background, white text,
          // and the message always says "Behaviour". Controller has
          // already refreshed the list, reset the form, and navigated
          // back to RouteName.behaviour by the time we get here. ──
          Get.snackbar(
            "Success",
            "Behaviour posted successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            "Error",
            "Failed to post Behaviour",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      },
      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      label: const Text(
        "Post Behaviour Activity",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
    ),
  );
}

Widget _timeBox(String label, RxString val, Function onTap) {
  return Obx(() {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                val.value.isEmpty ? label : val.value,
                style: TextStyle(
                  fontSize: 13,
                  color: val.value.isEmpty
                      ? Colors.grey.shade500
                      : Colors.black87,
                  fontWeight: val.value.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.access_time_rounded,
                size: 18, color: axisMaroonShade700),
          ],
        ),
      ),
    );
  });
}

Widget _activityField(Behaviourcontroller controller) {
  return TextFormField(
    controller: controller.activityController,
    maxLines: 3,
    decoration: InputDecoration(
      hintText: "Describe the behaviour...",
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: axisMaroonShade700, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}