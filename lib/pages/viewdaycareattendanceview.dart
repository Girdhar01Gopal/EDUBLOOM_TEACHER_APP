import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;
import '../models/session_model.dart';
import '../controller/viewdaycareattendancecontroller.dart';

class Viewdaycareattendanceview extends GetView<Viewdaycareattendancecontroller> {
  // ── Search state ───────────────────────────────────────────────────────────
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final TextEditingController _searchTextController = TextEditingController();

  Viewdaycareattendanceview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            /// ─── Filter Card ───────────────────────────────────────────
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

                  /// Session + Month
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return DropdownButtonFormField<session_model.sListDdata>(
                            value: controller.selectedSession.value,
                            hint: const Text("Select Session"),
                            isExpanded: true,
                            items: controller.sessionList
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.session ?? "",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                                .toList(),
                            onChanged: (v) =>
                            controller.selectedSession.value = v as sListDdata?,
                            decoration: _inputDecoration("Session"),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() {
                          return DropdownButtonFormField<String>(
                            value: controller.selectedMonth.value?['name']
                                ?.toString(),
                            hint: const Text("Select Month"),
                            isExpanded: true,
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

                  /// Search Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade300, Colors.pink.shade600],
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

            /// ─── Legend ────────────────────────────────────────────────
            _buildLegend(),

            const SizedBox(height: 10),

            /// ─── Student List ──────────────────────────────────────────
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

                // ── Name filter ────────────────────────────────────────
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
                    final int year = _getYearFromSession();
                    final int firstWeekday =
                        DateTime(year, monthId, 1).weekday;
                    final int startOffset =
                    firstWeekday == 7 ? 0 : firstWeekday;

                    int presentCount = 0, absentCount = 0;
                    for (int d = 1; d <= daysInMonth; d++) {
                      final normalized =
                      getNormalizedStatus(getDayStatus(s, d));
                      if (normalized == "present") presentCount++;
                      else if (normalized == "absent") absentCount++;
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

                          /// ── Card Header ──
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
                                          color:
                                          Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// ── Stat Chips ──
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                _statChip("Present", presentCount,
                                    Colors.green),
                                _statChip(
                                    "Absent", absentCount, Colors.red),
                              ],
                            ),
                          ),

                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEEEEEE)),

                          /// ── Calendar Grid ──
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildCalendarGrid(
                                s, daysInMonth, startOffset),
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

  // ─── AppBar with Search ───────────────────────────────────────────────────
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
            style:
            const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: "Search student by name…",
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14),
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
            "View Attendance Daycare",
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

  /// ─── Calendar Grid ────────────────────────────────────────────────────────
  Widget _buildCalendarGrid(student, int daysInMonth, int startOffset) {
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
          itemBuilder: (context, i) {
            if (i < startOffset) return const SizedBox.shrink();

            final day = i - startOffset + 1;
            final raw = getDayStatus(student, day);
            final normalized = getNormalizedStatus(raw);
            final code = getStatusCode(normalized);
            final color = getStatusColor(normalized);

            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
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
                      color: Colors.white,
                    ),
                  ),
                  if (code.isNotEmpty)
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String getNormalizedStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == "present") return "present";
    if (lower == "absent") return "absent";
    return lower;
  }

  String getStatusCode(String normalized) {
    switch (normalized) {
      case "present": return "P";
      case "absent":  return "A";
      default:        return "";
    }
  }

  Color getStatusColor(String normalized) {
    switch (normalized) {
      case "present": return Colors.green;
      case "absent":  return Colors.red;
      default:        return Colors.grey.shade400;
    }
  }

  int _getDaysInMonth(int monthId) {
    final year = _getYearFromSession();
    return DateTime(year, monthId + 1, 0).day;
  }

  int _getYearFromSession() {
    final sessionStr = controller.selectedSession.value?.session ?? "";
    if (sessionStr.contains("-")) {
      final parts = sessionStr.split("-");
      final parsed = int.tryParse(parts[0]);
      if (parsed != null) return parsed;
    }
    return DateTime.now().year;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(Colors.green, "Present"),
        const SizedBox(width: 14),
        _legendDot(Colors.red, "Absent"),
        const SizedBox(width: 14),
        _legendDot(Colors.grey.shade400, "N/A"),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
          BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
            const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            style:
            const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  String getDayStatus(student, int day) {
    switch (day) {
      case 1:  return student.day1  ?? "";
      case 2:  return student.day2  ?? "";
      case 3:  return student.day3  ?? "";
      case 4:  return student.day4  ?? "";
      case 5:  return student.day5  ?? "";
      case 6:  return student.day6  ?? "";
      case 7:  return student.day7  ?? "";
      case 8:  return student.day8  ?? "";
      case 9:  return student.day9  ?? "";
      case 10: return student.day10 ?? "";
      case 11: return student.day11 ?? "";
      case 12: return student.day12 ?? "";
      case 13: return student.day13 ?? "";
      case 14: return student.day14 ?? "";
      case 15: return student.day15 ?? "";
      case 16: return student.day16 ?? "";
      case 17: return student.day17 ?? "";
      case 18: return student.day18 ?? "";
      case 19: return student.day19 ?? "";
      case 20: return student.day20 ?? "";
      case 21: return student.day21 ?? "";
      case 22: return student.day22 ?? "";
      case 23: return student.day23 ?? "";
      case 24: return student.day24 ?? "";
      case 25: return student.day25 ?? "";
      case 26: return student.day26 ?? "";
      case 27: return student.day27 ?? "";
      case 28: return student.day28 ?? "";
      case 29: return student.day29 ?? "";
      case 30: return student.day30 ?? "";
      case 31: return student.day31 ?? "";
      default: return "";
    }
  }
}