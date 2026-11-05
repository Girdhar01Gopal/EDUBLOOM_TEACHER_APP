import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/addholidaycalendercontroller.dart';
import '../models/holiday_model.dart';

class AddHolidayCalendarScreen extends GetView<AddHolidayCalendarController> {
  const AddHolidayCalendarScreen({super.key});

  static const _holidayColor = Color(0xFF7E57C2); // deep purple 400
  static const _eventColor = Color(0xFFEF6C00); // orange 800
  static const _noteColor = Color(0xFF00897B); // teal 600
  static const _primaryColor = Color(0xFF97144D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Holiday/Event/Notes Calendar", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Add Holiday button hidden (commented out)
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: _holidayColor,
      //   foregroundColor: Colors.white,
      //   icon: const Icon(Icons.add),
      //   label: const Text("Add Holiday"),
      //   onPressed: () {
      //     controller.resetForm();
      //     _openHolidaySheet(context);
      //   },
      // ),
      body: Obx(() {
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.fetchAll,
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
    // Touch the lists so Obx rebuilds the grid when data loads.
    controller.holidayList.length;
    controller.notesList.length;
    controller.eventsList.length;

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
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _legend(Colors.amber.shade100, "Today"),
              _legend(_holidayColor.withValues(alpha: 0.18), "Holiday"),
              _legend(_eventColor.withValues(alpha: 0.18), "Event"),
              _legend(_noteColor.withValues(alpha: 0.18), "Note"),
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
              return const Expanded(child: SizedBox(height: 60));
            }
            final date = DateTime(month.year, month.month, dayNum);
            final holidays = controller.holidaysOn(date);
            final events = controller.eventsOn(date);
            final notes = controller.notesOn(date);

            final isHoliday = holidays.isNotEmpty;
            final isEvent = events.isNotEmpty;
            final isNote = notes.isNotEmpty;
            final hasAny = isHoliday || isEvent || isNote;
            final isToday = AddHolidayCalendarController.isSameDay(date, today);

            // Cell background / number color: Holiday > Event > Note
            final Color? accent = isHoliday
                ? _holidayColor
                : isEvent
                ? _eventColor
                : isNote
                ? _noteColor
                : null;

            // Cell ke andar dikhne wale labels (Holiday, Event, Note order)
            final labels = <_CellLabel>[
              ...holidays.map((h) => _CellLabel(h.occasion, _holidayColor)),
              ...events.map((e) => _CellLabel(e.title, _eventColor)),
              ...notes.map((n) => _CellLabel(n.title, _noteColor)),
            ];
            final visible = labels.length > 2
                ? [labels.first, _CellLabel("+${labels.length - 1} more", Colors.grey.shade700)]
                : labels;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onDateTap(context, date, holidays),
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.all(1.5),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: accent != null
                        ? accent.withValues(alpha: 0.18)
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
                          fontWeight: hasAny || isToday ? FontWeight.w800 : FontWeight.w500,
                          color: accent ??
                              (c == 0 ? Colors.red : Colors.black87),
                        ),
                      ),
                      if (hasAny)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: visible
                                  .map((l) => Text(
                                l.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 8.5,
                                    height: 1.15,
                                    color: l.color,
                                    fontWeight: FontWeight.w600),
                              ))
                                  .toList(),
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
      mainAxisSize: MainAxisSize.min,
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

  /// Date tap par us din ke Holiday / Event / Note ki detail alert dialog me dikhti hai.
  /// (Add / Edit holiday sheet abhi bhi hidden/commented hai.)
  void _onDateTap(BuildContext context, DateTime date, List<Holiday> holidays) {
    // Add / Edit holiday sheet hidden (commented out)
    // if (holidays.isEmpty) {
    //   controller.resetForm(date: date);
    // } else {
    //   controller.loadForEdit(holidays.first);
    // }
    // _openHolidaySheet(context);

    final events = controller.eventsOn(date);
    final notes = controller.notesOn(date);

    // Us din kuch bhi nahi hai to dialog nahi kholna
    if (holidays.isEmpty && events.isEmpty && notes.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          title: Row(
            children: [
              const Icon(Icons.event_note_rounded, color: _primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('EEEE, dd MMM yyyy').format(date),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (holidays.isNotEmpty) ...[
                    _dialogSectionTitle("Holiday", Icons.celebration, _holidayColor),
                    ...holidays.map((h) => _dialogItem(
                      color: _holidayColor,
                      title: h.occasion,
                      lines: const [],
                    )),
                  ],
                  if (events.isNotEmpty) ...[
                    _dialogSectionTitle("Event", Icons.event, _eventColor),
                    ...events.map((e) => _dialogItem(
                      color: _eventColor,
                      title: e.title,
                      lines: [
                        if ((e.place ?? '').isNotEmpty) "Place: ${e.place}",
                        if (e.classSections.isNotEmpty)
                          "Class: ${e.classSections.join(', ')}",
                        if ((e.description ?? '').isNotEmpty)
                          "Description: ${e.description}",
                        if ((e.createdBy ?? '').isNotEmpty)
                          "Created By: ${e.createdBy}",
                      ],
                    )),
                  ],
                  if (notes.isNotEmpty) ...[
                    _dialogSectionTitle("Note", Icons.menu_book, _noteColor),
                    ...notes.map((n) => _dialogItem(
                      color: _noteColor,
                      title: n.title,
                      lines: [
                        if (n.classSections.isNotEmpty)
                          "Class: ${n.classSections.join(', ')}",
                      ],
                    )),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(color: _primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogSectionTitle(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _dialogItem({
    required Color color,
    required String title,
    required List<String> lines,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ...lines.map((l) => Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(l,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
          )),
        ],
      ),
    );
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
          // Active / Inactive badge hidden (commented out)
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: h.isActive ? Colors.green.shade50 : Colors.grey.shade200,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     h.isActive ? "Active" : "Inactive",
          //     style: TextStyle(
          //       color: h.isActive ? Colors.green.shade700 : Colors.grey.shade600,
          //       fontWeight: FontWeight.w700,
          //       fontSize: 11,
          //     ),
          //   ),
          // ),
          // Edit button hidden (commented out)
          // IconButton(
          //   icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          //   onPressed: () {
          //     controller.loadForEdit(h);
          //     _openHolidaySheet(context);
          //   },
          // ),
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

/// Calendar cell ke andar ek chhota label (text + color).
class _CellLabel {
  final String text;
  final Color color;
  const _CellLabel(this.text, this.color);
}