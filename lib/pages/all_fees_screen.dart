import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/all_fees_controller.dart';
import '../models/all_fee_model.dart';

class AllFeesScreen extends GetView<AllFeesController> {
  const AllFeesScreen({super.key});

  static final _money =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // ✅ Axis Bank brand color
  static const _axisMaroon = Color(0xFF97144D);

  static const _paidColor = Color(0xFF2E7D32);
  static const _dueColor = Color(0xFFEF6C00);
  static const _pendingColor = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: _axisMaroon,
        elevation: 0,
        toolbarHeight: 75.h,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "All Fees",
          style: TextStyle(
              fontSize: 22.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final students = controller.filteredStudents;
        return RefreshIndicator(
          onRefresh: controller.fetchAllFees,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow(),
                      SizedBox(height: 14.h),
                      _dropdownRow(),
                      SizedBox(height: 12.h),
                      _statusChips(),
                      SizedBox(height: 10.h),
                      Text(
                        "${students.length} student${students.length == 1 ? '' : 's'}",
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (students.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text("No students found",
                        style:
                        TextStyle(fontSize: 14.sp, color: Colors.black54)),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 20.h),
                  sliver: SliverList.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) => _studentCard(students[i]),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ------------------ Summary ------------------
  Widget _summaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            "Total Collection",
            controller.totalCollection,
            Icons.account_balance_wallet_rounded,
            const [Color(0xFF97144D), Color(0xFFBE3A72)],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _summaryCard(
            "Total Due",
            controller.totalDue,
            Icons.pending_actions_rounded,
            const [Color(0xFFE65100), Color(0xFFFF8F00)],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _summaryCard(
            "Pending",
            controller.totalPending,
            Icons.hourglass_bottom_rounded,
            const [Color(0xFFC62828), Color(0xFFE53935)],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, double amount, IconData icon, List<Color> colors) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.25),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 8.h),
          Text(title,
              style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money.format(amount),
              style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Dropdowns ------------------
  Widget _dropdownRow() {
    final showClass = controller.typeFilter.value != FeeTypeFilter.daycare;
    return Column(
      children: [
        _dropdownBox(
          DropdownButton<FeeTypeFilter>(
            value: controller.typeFilter.value,
            isExpanded: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: FeeTypeFilter.all, child: Text("All")),
              DropdownMenuItem(
                  value: FeeTypeFilter.preschool, child: Text("Pre School")),
              DropdownMenuItem(
                  value: FeeTypeFilter.daycare, child: Text("Day Care")),
            ],
            onChanged: (v) {
              if (v != null) controller.setTypeFilter(v);
            },
          ),
        ),
        if (showClass) ...[
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _dropdownBox(
                  DropdownButton<int?>(
                    value: controller.selectedClassId.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text("All Classes")),
                      ...controller.classList
                          .where((c) => c.classId != null)
                          .map((c) => DropdownMenuItem<int?>(
                        value: c.classId,
                        child: Text(c.className ?? '',
                            overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: controller.setClass,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _dropdownBox(
                  DropdownButton<int?>(
                    value: controller.selectedSectionId.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text("All Sections")),
                      ...controller.sectionList
                          .map((s) => DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(s.name,
                            overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: controller.setSection,
                  ),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 10.h),
        _searchBar(),
      ],
    );
  }

  Widget _searchBar() {
    // Keyed so the typed text survives the class/section row hiding.
    return TextField(
      key: const ValueKey('allFeesSearch'),
      onChanged: controller.setSearch,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Search by student name",
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _dropdownBox(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  // ------------------ Status chips ------------------
  Widget _statusChips() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _chip("Fully Paid", FeeStatusFilter.fullyPaid,
            controller.countFor(FeeStatus.fullyPaid), _paidColor),
        _chip("Due", FeeStatusFilter.due, controller.countFor(FeeStatus.due),
            _dueColor),
        _chip("Pending", FeeStatusFilter.pending,
            controller.countFor(FeeStatus.pending), _pendingColor),
      ],
    );
  }

  Widget _chip(String label, FeeStatusFilter value, int count, Color color) {
    final selected = controller.statusFilter.value == value;
    return ChoiceChip(
      label: Text("$label ($count)"),
      selected: selected,
      onSelected: (_) => controller.toggleStatusFilter(value),
      selectedColor: color,
      backgroundColor: Colors.white,
      side: BorderSide(color: color.withOpacity(0.6)),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : color,
      ),
    );
  }

  // ------------------ Student card ------------------
  Widget _studentCard(AllFeeStudent s) {
    final (statusLabel, statusColor) = switch (s.status) {
      FeeStatus.fullyPaid => ("Fully Paid", _paidColor),
      FeeStatus.due => ("Due", _dueColor),
      FeeStatus.pending => ("Pending", _pendingColor),
    };
    final classText = s.category == FeeCategory.daycare
        ? "Day Care"
        : [s.className, s.section].where((e) => e.isNotEmpty).join(" - ");

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.studentName,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "${s.registrationNo}  •  $classText",
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _amount("Total", s.totalFee, Colors.black87),
              _amount("Paid", s.paidFee, _paidColor),
              _amount("Due", s.due, s.due > 0 ? _pendingColor : Colors.black45),
              if (s.discount > 0)
                _amount("Discount", s.discount, Colors.blueGrey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amount(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.black45)),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(_money.format(value),
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }
}