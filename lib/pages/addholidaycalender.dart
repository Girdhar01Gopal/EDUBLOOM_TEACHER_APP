import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/addholidaycalendercontroller.dart';
import '../models/holiday_model.dart';

class AddHolidayCalendarScreen extends GetView<AddHolidayCalendarController> {
  const AddHolidayCalendarScreen({super.key});

  static const _holidayColor = Color(0xFF7E57C2); // deep purple 400
  static const _primaryColor = Color(0xFF97144D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Holiday Calendar", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _holidayColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Holiday"),
        onPressed: () {
          controller.resetForm();
          _openHolidaySheet(context);
        },
      ),
      body: Obx(() {
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.fetchHolidays,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                children: [
                  _calendarCard(context),
                  const SizedBox(height: 16),
                  _holidayListCard(context),
                ],
              ),
            ),
            if (controller.isListLoading.value)
              const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator()),
          ],
        );
      }),
    );
  }

  // ═══════════════════════════════ Calendar ═══════════════════════════════
  Widget _calendarCard(BuildContext context) {
    final month = controller.focusedMonth.value;
    // Touch the list so Obx rebuilds the grid when holidays load.
    controller.holidayList.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _navButton(Icons.chevron_left, controller.previousMonth),
              const SizedBox(width: 4),
              _navButton(Icons.chevron_right, controller.nextMonth),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: controller.goToToday,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 34),
                ),
                child: const Text("Today"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                .map((d) => Expanded(
              child: Center(
                child: Text(d,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: d == "Sun" ? Colors.red : Colors.black87)),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 6),
          _monthGrid(context, month),
          const SizedBox(height: 10),
          Row(
            children: [
              _legend(Colors.amber.shade100, "Today"),
              const SizedBox(width: 16),
              _legend(_holidayColor.withValues(alpha: 0.18), "Holiday"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF2C3E50),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _monthGrid(BuildContext context, DateTime month) {
    // Sunday-first grid: DateTime.weekday is 1 (Mon) … 7 (Sun).
    final leading = DateTime(month.year, month.month, 1).weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((leading + daysInMonth) / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (r) {
        return Row(
          children: List.generate(7, (c) {
            final dayNum = r * 7 + c - leading + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 52));
            }
            final date = DateTime(month.year, month.month, dayNum);
            final holidays = controller.holidaysOn(date);
            final isHoliday = holidays.isNotEmpty;
            final isToday = AddHolidayCalendarController.isSameDay(date, today);

            return Expanded(
              child: GestureDetector(
                onTap: () => _onDateTap(context, date, holidays),
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.all(1.5),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isHoliday
                        ? _holidayColor.withValues(alpha: 0.18)
                        : isToday
                        ? Colors.amber.shade100
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isToday ? Colors.amber.shade700 : Colors.grey.shade300,
                      width: isToday ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$dayNum",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isHoliday || isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isHoliday
                              ? _holidayColor
                              : c == 0
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                      if (isHoliday)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              holidays.first.occasion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 8.5,
                                  color: _holidayColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  /// Empty date → add a holiday on it. Holiday date → edit it.
  void _onDateTap(BuildContext context, DateTime date, List<Holiday> holidays) {
    if (holidays.isEmpty) {
      controller.resetForm(date: date);
    } else {
      controller.loadForEdit(holidays.first);
    }
    _openHolidaySheet(context);
  }

  // ═══════════════════════════════ Holiday list ═══════════════════════════════
  Widget _holidayListCard(BuildContext context) {
    final list = controller.allHolidays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt_rounded, size: 20),
              const SizedBox(width: 6),
              const Text("Holiday List",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text("${list.length} total",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 10),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  controller.isListLoading.value ? "Loading…" : "No holidays added yet",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...List.generate(list.length, (i) => _holidayRow(context, i + 1, list[i])),
        ],
      ),
    );
  }

  Widget _holidayRow(BuildContext context, int sNo, Holiday h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: _holidayColor.withValues(alpha: 0.15),
            child: Text("$sNo",
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: _holidayColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.occasion,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  "${DateFormat('EEEE').format(h.dateHoliday)} • "
                      "${DateFormat('dd-MM-yyyy').format(h.dateHoliday)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: h.isActive ? Colors.green.shade50 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              h.isActive ? "Active" : "Inactive",
              style: TextStyle(
                color: h.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            onPressed: () {
              controller.loadForEdit(h);
              _openHolidaySheet(context);
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════ Add / edit sheet ═══════════════════════════════
  InputDecoration _decoration(String label, {bool required = true}) {
    return InputDecoration(
      labelText: required ? "$label *" : label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }

  void _openHolidaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 16),
          child: Obx(() {
            final date = controller.selectedDate.value;
            final saving = controller.isSaving.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.editingHdId.value == 0 ? "Add Holiday" : "Edit Holiday",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetContext,
                      initialDate: date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) controller.selectedDate.value = picked;
                  },
                  child: InputDecorator(
                    decoration: _decoration("Holiday Date").copyWith(
                      suffixIcon: const Icon(Icons.calendar_month),
                    ),
                    child: Text(date == null
                        ? "Select date"
                        : DateFormat('dd-MM-yyyy (EEEE)').format(date)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller.occasionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration("Occasion"),
                ),
                const SizedBox(height: 14),
                InputDecorator(
                  decoration: _decoration("Status", required: false),
                  child: Row(
                    children: [
                      Switch(
                        value: controller.isActive.value,
                        onChanged: (v) => controller.isActive.value = v,
                        activeColor: _primaryColor,
                      ),
                      Text(controller.isActive.value ? "Active" : "Inactive"),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: saving ? null : () => Navigator.of(sheetContext).pop(),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                        final ok = await controller.saveHoliday();
                        if (ok && sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: saving
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(controller.editingHdId.value == 0
                          ? "Save Holiday"
                          : "Update Holiday"),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }
}