import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/leave request controller.dart';
import '../models/leave apply model.dart' as leave_apply;
import '../models/leave balance dropdown model.dart' as leave_dropdown;

const MaterialColor axisMaroon = MaterialColor(0xFF97144D, <int, Color>{
  50: Color(0xFFF6E4EC),
  100: Color(0xFFE6B8CE),
  200: Color(0xFFD489AC),
  300: Color(0xFFC25A8B),
  400: Color(0xFFB3346F),
  500: Color(0xFF97144D),
  600: Color(0xFF861144),
  700: Color(0xFF700D39),
  800: Color(0xFF5A0A2E),
  900: Color(0xFF3D061E),
});

class LeaveRequestScreen extends GetView<LeaveRequestController> {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: axisMaroon.shade800,
          title: const Text(
            "🏖️ Leave Request",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: Get.back,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.edit_calendar, color: Colors.white),
                text: "Apply Leave",
              ),
              Tab(
                icon: Icon(Icons.view_list, color: Colors.white),
                text: "View Requests",
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [AddLeaveRequestTab(), ViewLeaveRequestTab()],
        ),
      ),
    );
  }
}

// ========================== ADD LEAVE REQUEST TAB ==========================
class AddLeaveRequestTab extends StatefulWidget {
  const AddLeaveRequestTab({super.key});

  @override
  State<AddLeaveRequestTab> createState() => _AddLeaveRequestTabState();
}

class _AddLeaveRequestTabState extends State<AddLeaveRequestTab> {
  final controller = Get.find<LeaveRequestController>();
  final dateFmt = DateFormat('dd-MM-yyyy');

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(
            Icons.calendar_today,
            color: axisMaroon.shade400,
            size: 18.sp,
          ),
        ),
        child: Text(
          value != null ? dateFmt.format(value) : "Select date",
          style: TextStyle(
            fontSize: 14.sp,
            color: value != null ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  void _openLeaveTypeSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeaveTypeSearchSheet(
        options: controller.leaveTypeList.toList(),
        selected: controller.selectedLeaveType.value,
        onSelected: (item) {
          controller.setSelectedLeaveType(item);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchLeaveTypes();
        await controller.fetchLeaveBalance();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Remaining leave days — one chip per leave type (parsed from
            // the logged-in user's GetAllLeveApp summary).
            Obx(() {
              if (controller.isBalanceLoading.value &&
                  controller.leaveBalanceRows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.leaveBalanceRows.isEmpty) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Leave Balance",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 74.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.leaveBalanceRows.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, i) {
                        final row = controller.leaveBalanceRows[i];
                        return Container(
                          width: 120.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: axisMaroon.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: axisMaroon.shade200),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  row.type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "${row.remaining} / ${row.total} left",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: axisMaroon.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Taken: ${row.taken}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }),

            // Leave Type — searchable, scrollable field (opens bottom sheet)
            Obx(
              () => _LeaveTypeSearchField(
                selected: controller.selectedLeaveType.value,
                onTap: () => _openLeaveTypeSearchSheet(context),
                isLoading: controller.isTypesLoading.value,
              ),
            ),

            // Balance available for the selected type (auto-filled, read-only)
            Obx(() {
              final sel = controller.selectedLeaveType.value;
              if (sel == null) return const SizedBox();
              final total = sel.totalLeave ?? sel.noOfDay ?? 0;
              return Padding(
                padding: EdgeInsets.only(top: 6.h, left: 4.w),
                child: Text(
                  "Balance available: ${sel.balanceLeave ?? 0} / $total",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: axisMaroon.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            SizedBox(height: 16.h),

            // From Date
            Obx(
              () => _dateField(
                label: "From Date",
                value: controller.fromDate.value,
                onTap: () => controller.pickFromDate(context),
              ),
            ),
            SizedBox(height: 16.h),

            // To Date
            Obx(
              () => _dateField(
                label: "To Date",
                value: controller.toDate.value,
                onTap: () => controller.pickToDate(context),
              ),
            ),
            SizedBox(height: 10.h),

            // Days count for the selected range
            Obx(() {
              final days = controller.selectedDaysCount;
              if (days <= 0) return const SizedBox();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: axisMaroon.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16.sp,
                      color: axisMaroon.shade600,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      days == 1 ? "1 Day" : "$days Days",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: axisMaroon.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 16.h),

            // Reason
            TextField(
              controller: TextEditingController(text: controller.reason.value)
                ..selection = TextSelection.collapsed(
                  offset: controller.reason.value.length,
                ),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => controller.reason.value = val,
            ),
            SizedBox(height: 16.h),

            Text(
              "Attachment (optional)",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final file = controller.attachmentFile.value;
              return GestureDetector(
                onTap: controller.pickAttachment,
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    border: Border.all(color: axisMaroon.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(12.r),
                    color: axisMaroon.shade50,
                  ),
                  child: file != null
                      ? Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color: axisMaroon.shade600,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                file.path.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: controller.removeAttachment,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(Icons.attach_file, color: axisMaroon.shade400),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "Tap to attach a file (PDF / Image)",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: axisMaroon.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),

            SizedBox(height: 24.h),

            Obx(
              () => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade300, Colors.pink.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ElevatedButton.icon(
                  icon: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    controller.isSubmitting.value
                        ? "Submitting..."
                        : "Submit Leave Request",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.applyLeaveRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

// ========================== VIEW LEAVE REQUEST TAB ==========================
class ViewLeaveRequestTab extends StatefulWidget {
  const ViewLeaveRequestTab({super.key});

  @override
  State<ViewLeaveRequestTab> createState() => _ViewLeaveRequestTabState();
}

class _ViewLeaveRequestTabState extends State<ViewLeaveRequestTab> {
  final controller = Get.find<LeaveRequestController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLeaveRequests();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'cancelled':
        return Colors.grey.shade600;
      case 'pending':
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      case 'pending':
      default:
        return Icons.hourglass_top;
    }
  }

  void _confirmCancel(int leaveId) {
    Get.defaultDialog(
      title: "Cancel Leave Request",
      middleText: "Are you sure you want to cancel this leave request?",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: axisMaroon,
      onConfirm: () {
        Get.back();
        controller.cancelLeaveRequest(leaveId);
      },
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchLeaveRequests,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.leaveRequestList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.leaveRequestList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No leave requests found')),
              ],
            );
          }

          final list = controller.leaveRequestList;

          return Column(
            children: [
              Row(
                children: [
                  _summaryChip(
                    "Pending",
                    controller.pendingCount,
                    Colors.orange.shade700,
                  ),
                  _summaryChip(
                    "Approved",
                    controller.approvedCount,
                    Colors.green.shade600,
                  ),
                  _summaryChip(
                    "Rejected",
                    controller.rejectedCount,
                    Colors.red.shade600,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final leave_apply.LeaveData item = list[index];

                    final leaveType = item.leave ?? 'N/A';
                    final from = formatDate(item.fromDate);
                    final to = formatDate(item.toDate);
                    final reason = item.reasonforLeave ?? 'No reason provided';
                    final status = item.status ?? 'Pending';
                    final appliedOn = formatDate(item.createdate);
                    final isPending = status.toLowerCase() == 'pending';
                    final daysCount = controller.daysCountForRequest(item);

                    return Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 34.r,
                                  width: 34.r,
                                  decoration: BoxDecoration(
                                    color: axisMaroon.shade50,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.event_note,
                                    color: axisMaroon[700],
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    leaveType,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _statusIcon(status),
                                          size: 14.sp,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            status,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Divider(color: Colors.grey.shade300, height: 1),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "From: $from   To: $to",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (daysCount > 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: axisMaroon.shade50,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: axisMaroon.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      daysCount == 1
                                          ? "1 Day"
                                          : "$daysCount Days",
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: axisMaroon.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              reason,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade800,
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Applied on: $appliedOn",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            if (isPending) ...[
                              SizedBox(height: 10.h),
                              // Align(
                              //   alignment: Alignment.centerRight,
                              //   child: TextButton.icon(
                              //     onPressed: () => _confirmCancel(item.leaveId ?? 0),
                              //     icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              //     label: const Text("Cancel Request", style: TextStyle(color: Colors.red)),
                              //   ),
                              // ),
                            ],
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
    );
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd-MM-yyyy').format(date);
}

// ================= LEAVE TYPE — SEARCHABLE FIELD (tap target) =================
class _LeaveTypeSearchField extends StatelessWidget {
  final leave_dropdown.LeaveBalanceData? selected;
  final VoidCallback onTap;
  final bool isLoading;

  const _LeaveTypeSearchField({
    required this.selected,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Leave Type',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: isLoading
              ? Padding(
                  padding: EdgeInsets.all(12.r),
                  child: const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(Icons.search, color: axisMaroon.shade400, size: 20.sp),
        ),
        child: Text(
          selected?.leave ?? "Search & select leave type",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: selected != null ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// ================= LEAVE TYPE — SEARCHABLE, SCROLLABLE BOTTOM SHEET =================
class _LeaveTypeSearchSheet extends StatefulWidget {
  final List<leave_dropdown.LeaveBalanceData> options;
  final leave_dropdown.LeaveBalanceData? selected;
  final ValueChanged<leave_dropdown.LeaveBalanceData> onSelected;

  const _LeaveTypeSearchSheet({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_LeaveTypeSearchSheet> createState() => _LeaveTypeSearchSheetState();
}

class _LeaveTypeSearchSheetState extends State<_LeaveTypeSearchSheet> {
  final _searchCtrl = TextEditingController();
  late List<leave_dropdown.LeaveBalanceData> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.options;
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.options
          : widget.options
                .where((e) => (e.leave ?? '').toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.7;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                  child: Text(
                    "Select Leave Type",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: false,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search leave type...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearchChanged("");
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: axisMaroon.shade50,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 12.w,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Divider(height: 1, color: Colors.grey.shade200),
                Flexible(
                  child: _filtered.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          child: Center(
                            child: Text(
                              "No matching leave type",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (context, index) {
                            final item = _filtered[index];
                            final isSelected =
                                item.leaveId == widget.selected?.leaveId;
                            final total = item.totalLeave ?? item.noOfDay ?? 0;
                            return ListTile(
                              dense: true,
                              title: Text(
                                item.leave ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? axisMaroon.shade700
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                "Balance: ${item.balanceLeave ?? 0} / $total",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: axisMaroon.shade600,
                                      size: 20.sp,
                                    )
                                  : null,
                              onTap: () => widget.onSelected(item),
                            );
                          },
                        ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
