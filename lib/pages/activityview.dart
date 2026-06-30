import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/activitycontroller.dart';
import '../models/activitystudentmodel.dart';

class Activityview extends GetView<Activitycontroller> {
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
          backgroundColor: Colors.teal.shade800,
          title: Text(
            "Activity",
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
              Tab(text: "Add Activity"),
              Tab(text: "View Activity"),
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
//  ADD ACTIVITY TAB
// ══════════════════════════════════════
class PostActivity extends GetView<Activitycontroller> {
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
                colors: [Colors.teal.shade700, Colors.teal.shade400],
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
                  child: Icon(Icons.directions_run_rounded,
                      color: Colors.white, size: 26.r),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Post New Activity",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Fill details to record student activity",
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
                _sectionLabel("Select Student", Icons.person_rounded),
                SizedBox(height: 8.h),
                _studentDropdown(controller),

                SizedBox(height: 16.h),
                _sectionLabel("Activity Description", Icons.edit_note_rounded),
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

          // ✅ Submit button — fixed
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
      Icon(icon, size: 16, color: Colors.teal.shade700),
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

// ══════════════════════════════════════
//  VIEW ACTIVITY TAB
// ══════════════════════════════════════
class ViewActivityScreen extends GetView<Activitycontroller> {
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
    return Obx(() {
      if (controller.activityList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
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

      return ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: controller.activityList.length,
        itemBuilder: (context, index) {
          final act = controller.activityList[index];
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.pink.shade200],
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
                          Icons.directions_run_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          act.activity ?? "No Activity",
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                              iconColor: Colors.teal,
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
    });
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
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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

Widget _timeRow(Activitycontroller controller) {
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

// ✅ FIXED submit button — selectedStudentIds.first crash se bachao
Widget _submitButton(Activitycontroller controller) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: () async {
        // ✅ Pehle check karo ki student select hua hai ya nahi
        if (controller.selectedStudentIds.isEmpty) {
          Get.snackbar(
            "Validation",
            "Please select a student first.",
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade800,
            icon: const Icon(Icons.warning_amber_rounded,
                color: Colors.orange),
          );
          return;
        }

        final studentId = controller.selectedStudentIds.first;

        // ✅ studentId = 0 hone par bhi block karo
        if (studentId == 0) {
          Get.snackbar(
            "Error",
            "Student ID is invalid. Please re-select the student.",
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800,
            icon: const Icon(Icons.error, color: Colors.red),
          );
          return;
        }

        final success = await controller.postActivityToApi(studentId);

        if (success) {
          Get.snackbar(
            "Success",
            "Activity posted successfully",
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800,
            icon: const Icon(Icons.check_circle, color: Colors.green),
          );
        } else {
          Get.snackbar(
            "Error",
            "Failed to post activity",
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      },
      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      label: const Text(
        "Post Activity",
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
                  color:
                  val.value.isEmpty ? Colors.grey.shade500 : Colors.black87,
                  fontWeight: val.value.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.access_time_rounded,
                size: 18, color: Colors.teal.shade600),
          ],
        ),
      ),
    );
  });
}

Widget _activityField(Activitycontroller controller) {
  return TextFormField(
    controller: controller.activityController,
    maxLines: 3,
    decoration: InputDecoration(
      hintText: "Describe the activity...",
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
        borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

Widget _studentDropdown(Activitycontroller controller) {
  return Obx(() {
    return DropdownButtonFormField<Data>(
      decoration: InputDecoration(
        hintText: "Choose a student",
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
          borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      value: controller.selectedStudent.isEmpty
          ? null
          : controller.selectedStudent.first,
      items: controller.studentList.map((student) {
        return DropdownMenuItem<Data>(
          value: student,
          child: Text(student.studentName ?? "Unnamed"),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          controller.selectedStudent.clear();
          controller.selectedStudentIds.clear();
        } else {
          controller.selectedStudent.assignAll([value]);
          controller.selectedStudentIds
            ..clear()
            ..add(value.studentId ?? 0);
        }
      },
    );
  });
}

Widget _typeDropdown(Activitycontroller controller) {
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
          borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
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
        controller.selecttype.value = value!;
        controller.selectedStudentIds.clear();
        controller.selectedStudent.clear();
        controller.fetchStudents();
      },
    );
  });
}