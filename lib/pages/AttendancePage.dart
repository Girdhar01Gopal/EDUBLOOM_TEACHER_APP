import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;
import '../controller/AttendanceController.dart';
import '../models/AttendanceModel.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildFilterCard(context),
                  const SizedBox(height: 14),
                  _buildAlreadyMarkedBanner(),
                  _buildStudentList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── AppBar with Search ───────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final searching = controller.isSearching.value;
        return AppBar(
          backgroundColor: const Color(0xFF97144D),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              searching ? Icons.arrow_back : Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (searching) {
                controller.toggleSearch();
              } else {
                Get.back();
              }
            },
          ),
          title: searching
              ? TextField(
            controller: controller.searchController,
            autofocus: true,
            onChanged: controller.onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: "Search student by name…",
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14),
              border: InputBorder.none,
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? GestureDetector(
                onTap: controller.clearSearch,
                child: const Icon(Icons.close,
                    color: Colors.white, size: 20),
              )
                  : const SizedBox.shrink()),
            ),
          )
              : const Text(
            "Take Attendance",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          actions: [
            // Show search icon only when student list is non-empty
            Obx(() {
              if (searching) return const SizedBox.shrink();
              if (controller.students.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                tooltip: "Search Student",
                onPressed: controller.toggleSearch,
              );
            }),
          ],
        );
      }),
    );
  }

  // ─── Already-marked Banner ─────────────────────────────────────────────────
  Widget _buildAlreadyMarkedBanner() {
    return Obx(() {
      if (!controller.isAttendanceAlreadyMarked.value ||
          controller.students.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          children: [
            // Icon(Icons.event_available_rounded,
            //     color: Colors.blue.shade600, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "",
                style: TextStyle(
                    fontSize: 12,
                    //color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Filter Card ──────────────────────────────────────────────────────────
  Widget _buildFilterCard(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // ── Row 1: Session + Class ────────────────────────────────────
          Obx(() => Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<session_model.sListDdata>(
                  value: controller.selectedSession.value,
                  hint: const Text("Select Session",
                      style: TextStyle(fontSize: 13)),
                  isExpanded: true,
                  onChanged: controller.setSelectedSession,
                  items: controller.sessionList.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.session ?? 'No session',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  decoration: _inputDecoration('Session'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<ListDataa>(
                  value: controller.selectedClass.value,
                  hint: const Text("Select Class",
                      style: TextStyle(fontSize: 13)),
                  isExpanded: true,
                  items: controller.listDataa.map((item) {
                    return DropdownMenuItem<ListDataa>(
                      value: item,
                      child: Text(item.className ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: controller.setSelectedClass,
                  decoration: _inputDecoration('Class'),
                ),
              ),
            ],
          )),

          const SizedBox(height: 12),

          // ── Row 2: Section + Date ─────────────────────────────────────
          Obx(() => Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ListDatta>(
                  value: controller.selectedSection.value,
                  hint: const Text("Select Section",
                      style: TextStyle(fontSize: 13)),
                  isExpanded: true,
                  items: controller.sectionList.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item.section ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: controller.setSelectedSection,
                  decoration: _inputDecoration('Section'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: controller.dateController,
                  readOnly: true,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    labelStyle: const TextStyle(fontSize: 11),
                    prefixIcon: const Icon(Icons.calendar_month_rounded,
                        color: Color(0xFF97144D), size: 16),
                    prefixIconConstraints: const BoxConstraints(
                        minWidth: 32, minHeight: 32),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 12),
                    isDense: true,
                  ),
                  onTap: () async {
                    final today = DateTime.now();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: today,
                      firstDate: DateTime(2000),
                      lastDate: today,
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF97144D),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      ),
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
          )),

          const SizedBox(height: 12),

          // ── Manage Attendance Button ──────────────────────────────────
          Obx(() => Align(
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
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.viewStudent(),
                icon: controller.isLoading.value
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.manage_search,
                    color: Colors.white, size: 18),
                label: const Text(
                  "Manage Attendance",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Student List ─────────────────────────────────────────────────────────
  Widget _buildStudentList() {
    return Obx(() {
      final bool loading = controller.isLoading.value;

      // Read both observables so GetX tracks them
      controller.students.length;
      final String query = controller.searchQuery.value;

      if (loading) {
        return const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.students.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline,
                    size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text("No Students Found",
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade500)),
              ],
            ),
          ),
        );
      }

      // ── Apply search filter ──────────────────────────────────────────
      final filtered = controller.filteredStudents;

      if (filtered.isEmpty && query.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 54, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  'No student found for "$query"',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final student = filtered[index];
          return _StudentCard(
            key: ValueKey(student.studentID ?? index),
            student: student,
            onStatusChanged: (status) {
              // Find original index in full list and update
              final origIndex = controller.students
                  .indexWhere((s) => s.studentID == student.studentID);
              if (origIndex != -1) {
                controller.students[origIndex].action = status;
              }
            },
          );
        },
      );
    });
  }

  // ─── Bottom Submit Button ─────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return BottomAppBar(
      color: const Color(0xFF97144D),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.pink.shade500],
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
          child: Obx(() => ElevatedButton.icon(
            onPressed: controller.isSubmitting.value
                ? null
                : () => controller.manageAttendance(),
            icon: controller.isSubmitting.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            label: controller.isSubmitting.value
                ? const Text("Submitting…",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold))
                : const Text("Submit Attendance",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }
}

// ─── Student Card ─────────────────────────────────────────────────────────────
class _StudentCard extends StatefulWidget {
  final ListData student;
  final ValueChanged<String> onStatusChanged;

  const _StudentCard({
    super.key,
    required this.student,
    required this.onStatusChanged,
  });

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard> {
  late String selectedStatus;

  static const List<String> options = [
    "Present",
    "Absent",
    "WeekOff",
    "Halfday",
  ];

  @override
  void initState() {
    super.initState();
    final api = widget.student.action ?? "";
    selectedStatus = options.contains(api) ? api : "Present";
    widget.student.action = selectedStatus;
  }

  Color _colorFor(String s) {
    switch (s) {
      case "Present":
        return Colors.green;
      case "Absent":
        return Colors.red;
      case "WeekOff":
        return Colors.blueGrey;
      case "Halfday":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final statusColor = _colorFor(selectedStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        children: [
          // ── Card Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (s.studentName?.isNotEmpty == true)
                        ? s.studentName![0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.studentName ?? "No Name",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: statusColor.withOpacity(0.7)),
                  ),
                  child: Text(
                    selectedStatus,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ),

          // ── Status Buttons ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            child: Row(
              children: options.map((option) {
                final isSelected = selectedStatus == option;
                final optColor = _colorFor(option);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedStatus = option);
                        widget.student.action = option;
                        widget.onStatusChanged(option);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? optColor
                              : optColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? optColor
                                : optColor.withOpacity(0.4),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: optColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                              isSelected ? Colors.white : optColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}