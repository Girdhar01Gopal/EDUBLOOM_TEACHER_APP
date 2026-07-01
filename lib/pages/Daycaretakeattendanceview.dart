import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;

import '../controller/Daycareattendencecontroller.dart';

class Daycaretakeattendanceview extends GetView<Daycareattendencecontroller> {
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final TextEditingController _searchTextController = TextEditingController();

  Daycaretakeattendanceview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          final query = _searchQuery.value.trim().toLowerCase();
          final filtered = query.isEmpty
              ? controller.students
              : controller.students
              .where((s) =>
              (s.studentName ?? '').toLowerCase().contains(query))
              .toList();

          return Column(
            children: [
              // ── Session + Date ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<session_model.sListDdata>(
                      value: controller.selectedSession.value,
                      hint: const Text("Select Session"),
                      isExpanded: true,
                      onChanged: (newVal) =>
                          controller.setSelectedSession(newVal),
                      items: controller.sessionList.map((session) {
                        return DropdownMenuItem(
                          value: session,
                          child: Text(session.session ?? 'No session'),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Session',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: controller.dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                        prefixIcon: Icon(Icons.calendar_month_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onTap: () async {
                        final today = DateTime.now();
                        DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: DateTime(2000),
                          lastDate: today,
                        );
                        if (selected != null) {
                          final d =
                          selected.day.toString().padLeft(2, '0');
                          final m =
                          selected.month.toString().padLeft(2, '0');
                          final y = selected.year.toString();
                          controller.dateController.text = "$d-$m-$y";
                          controller.selectedRawDate.value = "$y-$m-$d";
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Manage Attendance Button ──────────────────────────────
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
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.viewStudent(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                    ),
                    child: const Text(
                      "Manage Attendance",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Student List ──────────────────────────────────────────
              Expanded(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.students.isEmpty
                    ? const Center(child: Text("No Students Found"))
                    : filtered.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search,
                          size: 60,
                          color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No student found for "$query"',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    final realIndex = controller.students
                        .indexWhere((s) =>
                    s.studentID == student.studentID);

                    return Container(
                      margin:
                      const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          student.studentName ?? "No Name",
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: student.action ==
                                      'Present',
                                  onChanged: (value) {
                                    controller
                                        .updateAttendanceStatus(
                                      realIndex,
                                      value == true
                                          ? 'Present'
                                          : 'Absent',
                                    );
                                  },
                                ),
                                const Text("Present"),
                                Checkbox(
                                  value: student.action ==
                                      'Absent',
                                  onChanged: (value) {
                                    controller
                                        .updateAttendanceStatus(
                                      realIndex,
                                      value == true
                                          ? 'Absent'
                                          : 'Present',
                                    );
                                  },
                                ),
                                const Text("Absent"),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                    TextEditingController(
                                      text: student.fromTime ??
                                          '',
                                    ),
                                    readOnly: true,
                                    decoration:
                                    const InputDecoration(
                                      labelText: 'Start Time',
                                      border:
                                      OutlineInputBorder(),
                                    ),
                                    onTap: () async {
                                      if (student.action ==
                                          'Absent') return;
                                      final TimeOfDay?
                                      pickedStartTime =
                                      await showTimePicker(
                                        context: context,
                                        initialTime:
                                        TimeOfDay.now(),
                                      );
                                      if (pickedStartTime !=
                                          null) {
                                        // ── FIX: 24hr format ──
                                        controller
                                            .updateStudentFromTime(
                                          realIndex,
                                          controller.formatTime(
                                              pickedStartTime),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                    TextEditingController(
                                      text:
                                      student.toTime ?? '',
                                    ),
                                    readOnly: true,
                                    decoration:
                                    const InputDecoration(
                                      labelText: 'End Time',
                                      border:
                                      OutlineInputBorder(),
                                    ),
                                    onTap: () async {
                                      if (student.action ==
                                          'Absent') return;
                                      final TimeOfDay?
                                      pickedEndTime =
                                      await showTimePicker(
                                        context: context,
                                        initialTime:
                                        TimeOfDay.now(),
                                      );
                                      if (pickedEndTime !=
                                          null) {
                                        // ── FIX: 24hr format ──
                                        controller
                                            .updateStudentToTime(
                                          realIndex,
                                          controller.formatTime(
                                              pickedEndTime),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF97144D),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade300, Colors.pink.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
                  () => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.manageAttendance(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                      vertical: 12.h, horizontal: 16.w),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  "Submit Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final searching = _isSearching.value;
        return AppBar(
          backgroundColor: const Color(0xFF97144D),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (searching) {
                _isSearching.value = false;
                _searchQuery.value = '';
                _searchTextController.clear();
              } else {
                Get.back();
              }
            },
          ),
          title: searching
              ? TextField(
            controller: _searchTextController,
            autofocus: true,
            onChanged: (v) => _searchQuery.value = v,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: "Search student by name…",
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14),
              border: InputBorder.none,
              suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  _searchQuery.value = '';
                  _searchTextController.clear();
                },
                child: const Icon(Icons.close,
                    color: Colors.white, size: 20),
              )
                  : const SizedBox.shrink()),
            ),
          )
              : const Text(
            "Day Care Attendance",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Obx(() {
              if (_isSearching.value) return const SizedBox.shrink();
              if (controller.students.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                tooltip: "Search by name",
                onPressed: () => _isSearching.value = true,
              );
            }),
          ],
        );
      }),
    );
  }
}