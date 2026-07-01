import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;
import '../controller/View_AttendanceController.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

class ViewAttendancePage extends GetView<ViewAttendanceController> {
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final TextEditingController _searchTextController = TextEditingController();

  ViewAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return DropdownButtonFormField<session_model.sListDdata>(
                            value: controller.selectedSession.value,
                            hint: const Text("Select Session"),
                            isExpanded: true,
                            onChanged: (newVal) {
                              controller.setSelectedSession(newVal!);
                              controller.session.value = newVal.session ?? "";
                            },
                            items: controller.sessionList.map((session) {
                              return DropdownMenuItem(
                                value: session,
                                child: Text(
                                  session.session ?? 'No session',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            decoration: _inputDecoration("Session"),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() {
                          return DropdownButtonFormField<ListDataa>(
                            value: controller.selectedClass.value,
                            hint: const Text("Select Class"),
                            isExpanded: true,
                            items: controller.listDataa.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(c.className ?? "",
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) =>
                            controller.selectedClass.value = v,
                            decoration: _inputDecoration("Class"),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return DropdownButtonFormField<ListDatta>(
                            value: controller.selectedSection.value,
                            hint: const Text("Select Section"),
                            isExpanded: true,
                            items: controller.sectionList.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.section ?? "",
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) =>
                            controller.selectedSection.value = v,
                            decoration: _inputDecoration("Section"),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() {
                          return DropdownButtonFormField<String>(
                            value: controller.selectedMonth.value?['name']
                                ?.toString(),
                            items: controller.months
                                .map((m) => DropdownMenuItem<String>(
                              value: (m['name'] ?? '').toString(),
                              child: Text(
                                  (m['name'] ?? '').toString()),
                            ))
                                .toList(),
                            onChanged: (v) {
                              controller.setSelectedMonth(v!);
                              controller.searchAttendance();
                            },
                            decoration: _inputDecoration("Month"),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade300,
                            Colors.pink.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade200.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => controller.searchAttendance(),
                        icon: const Icon(Icons.search,
                            color: Colors.white, size: 18),
                        label: const Text(
                          "Search",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 20.w),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _buildLegend(),
            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          "No Attendance Found",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                final query = _searchQuery.value.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? controller.students
                    : controller.students
                    .where((s) => (s.studentName ?? '')
                    .toLowerCase()
                    .contains(query))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No student found for "$query"',
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    final monthId =
                        controller.selectedMonth.value?['id'] as int? ?? 1;
                    final daysInMonth = _getDaysInMonth(monthId);
                    final int year = controller.getYearFromSession();
                    final int firstWeekday =
                        DateTime(year, monthId, 1).weekday;
                    final int startOffset =
                    firstWeekday == 7 ? 0 : firstWeekday;

                    int presentCount = 0,
                        absentCount = 0,
                        halfDayCount = 0,
                        weekoffCount = 0;

                    for (int d = 1; d <= daysInMonth; d++) {
                      final status =
                      getNormalizedStatus(getDayStatus(s, d));
                      if (status == "present") presentCount++;
                      else if (status == "absent") absentCount++;
                      else if (status == "halfday") halfDayCount++;
                      else if (status == "weekoff") weekoffCount++;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF97144D),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                  Colors.white.withOpacity(0.2),
                                  child: Text(
                                    (s.studentName?.isNotEmpty == true)
                                        ? s.studentName![0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.studentName ?? "No Name",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        s.className ?? "",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statChip("Present", presentCount, Colors.green),
                                _statChip("Absent", absentCount, Colors.red),
                                _statChip("Half Day", halfDayCount,
                                    Colors.purple.shade400),
                                _statChip(
                                    "Week Off", weekoffCount, Colors.blueGrey),
                              ],
                            ),
                          ),

                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEEEEEE)),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildCalendarGrid(
                                context, s, daysInMonth, startOffset),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
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
            "View Attendance",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildCalendarGrid(
      BuildContext context, student, int daysInMonth, int startOffset) {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  dayLabels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (i == 0 || i == 6)
                        ? Colors.red.shade400
                        : const Color(0xFF97144D),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (ctx, i) {
            if (i < startOffset) return const SizedBox.shrink();

            final day = i - startOffset + 1;
            final rawStatus = getDayStatus(student, day);
            final normalized = getNormalizedStatus(rawStatus);
            final code = getStatusCode(normalized);
            final color = getStatusColor(normalized);
            final hasAttendance = rawStatus.trim().isNotEmpty;

            return GestureDetector(
              onTap: hasAttendance
                  ? () => _showEditBottomSheet(
                  context, student, day, normalized)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                  border: hasAttendance
                      ? Border.all(
                      color: Colors.white.withOpacity(0.4), width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$day",
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    if (code.isNotEmpty)
                      Text(code,
                          style: const TextStyle(
                              fontSize: 8, color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showEditBottomSheet(
      BuildContext context, student, int day, String currentStatus) {
    final List<Map<String, dynamic>> statuses = [
      {"label": "Present", "key": "Present", "color": Colors.green as Color},
      {"label": "Absent", "key": "Absent", "color": Colors.red as Color},
      {
        "label": "Half Day",
        "key": "Halfday",
        "color": Colors.purple.shade400 as Color,
      },
      {
        "label": "Week Off",
        "key": "WeekOff",
        "color": Colors.blueGrey as Color,
      },
    ];

    final monthId = controller.selectedMonth.value?['id'] as int? ?? 1;
    final year = controller.getYearFromSession();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${student.studentName ?? 'Student'} — $day ${_monthName(monthId)} $year",
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Current: $currentStatus",
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Row(
                children: statuses.map((s) {
                  final String key = s["key"] as String;
                  final String label = s["label"] as String;
                  final Color color = s["color"] as Color;
                  final bool isCurrent =
                      currentStatus.toLowerCase() == key.toLowerCase();

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: isCurrent
                            ? null
                            : () async {
                          Get.back(); // ← fixed
                          final ok = await controller.editAttendance(
                            studentId: student.studentID ?? 0,
                            status: key,
                            day: day,
                          );
                          if (ok) {
                            Get.snackbar(
                              "Updated",
                              "${student.studentName} marked $label for $day/${_monthName(monthId)}",
                              backgroundColor: Colors.green.shade600,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              borderRadius: 14,
                              margin: const EdgeInsets.all(12),
                            );
                            controller.searchAttendance();
                          } else {
                            Get.snackbar(
                              "Failed",
                              "Could not update attendance",
                              backgroundColor: Colors.red.shade600,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              borderRadius: 14,
                              margin: const EdgeInsets.all(12),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isCurrent ? color.withOpacity(0.3) : color,
                          padding:
                          const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _monthName(int id) {
    const names = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return id >= 1 && id <= 12 ? names[id] : '';
  }

  String getNormalizedStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == "present") return "present";
    if (lower == "absent") return "absent";
    if (lower == "halfday" || lower == "half day") return "halfday";
    if (lower == "weekoff" || lower == "week off") return "weekoff";
    return lower;
  }

  String getStatusCode(String normalized) {
    switch (normalized) {
      case "present":
        return "P";
      case "absent":
        return "A";
      case "halfday":
        return "H/D";
      case "weekoff":
        return "W/O";
      default:
        return "";
    }
  }

  Color getStatusColor(String normalized) {
    switch (normalized) {
      case "present":
        return Colors.green;
      case "absent":
        return Colors.red;
      case "halfday":
        return Colors.purple.shade400;
      case "weekoff":
        return Colors.blueGrey;
      default:
        return Colors.grey.shade400;
    }
  }

  int _getDaysInMonth(int monthId) {
    final year = controller.getYearFromSession();
    return DateTime(year, monthId + 1, 0).day;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(Colors.green, "Present"),
        const SizedBox(width: 10),
        _legendDot(Colors.red, "Absent"),
        const SizedBox(width: 10),
        _legendDot(Colors.purple.shade400, "Half Day"),
        const SizedBox(width: 10),
        _legendDot(Colors.blueGrey, "Week Off"),
        const SizedBox(width: 10),
        _legendDot(Colors.grey, "N/A"),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  List<String?> _getStudentDayValues(student) {
    return [
      student.day1,  student.day2,  student.day3,  student.day4,
      student.day5,  student.day6,  student.day7,  student.day8,
      student.day9,  student.day10, student.day11, student.day12,
      student.day13, student.day14, student.day15, student.day16,
      student.day17, student.day18, student.day19, student.day20,
      student.day21, student.day22, student.day23, student.day24,
      student.day25, student.day26, student.day27, student.day28,
      student.day29, student.day30, student.day31,
    ];
  }

  String getDayStatus(student, int day) {
    final days = _getStudentDayValues(student);
    if (day < 1 || day > days.length) return "";
    return days[day - 1] ?? "";
  }
}