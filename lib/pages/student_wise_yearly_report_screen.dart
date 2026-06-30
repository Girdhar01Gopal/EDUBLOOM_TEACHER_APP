// ── File: screens/student_wise_yearly_report_screen.dart ──────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/student_wise_yearly_report_controller.dart';
import '../models/session_model.dart';
import '../wigets/app_drawer.dart';

class StudentWiseYearlyReportScreen extends StatelessWidget {
  const StudentWiseYearlyReportScreen({super.key});

  // ── Summary card data ────────────────────────────────────────────────────
  List<_CardData> _buildCards(StudentWiseYearlyReportController c) => [
    _CardData(
      label: 'TOTAL STUDENTS',
      value: '${c.totalStudents}',
      icon: '👤',
      color: const Color(0xFF7C4DFF),
      isAmount: false,
    ),
    _CardData(
      label: 'TOTAL FEE ASSIGNED',
      value: _fmt(c.sumTotalFee),
      icon: '💰',
      color: const Color(0xFF0288D1),
      isAmount: true,
    ),
    _CardData(
      label: 'TOTAL DISCOUNT GIVEN',
      value: _fmt(c.sumTotalDiscount),
      icon: '🏷️',
      color: const Color(0xFF00897B),
      isAmount: true,
    ),
    _CardData(
      label: 'NET COLLECTED',
      value: _fmt(c.sumNetFee),
      icon: '💵',
      color: const Color(0xFF0097A7),
      isAmount: true,
    ),
    _CardData(
      label: 'TOTAL PAID',
      value: _fmt(c.sumTotalPaid),
      icon: '✅',
      color: const Color(0xFF2E7D32),
      isAmount: true,
    ),
    _CardData(
      label: 'OUTSTANDING',
      value: _fmt(c.sumTotalDue),
      icon: '⚠️',
      color: const Color(0xFFE65100),
      isAmount: true,
    ),
  ];

  static String _fmt(double v) {
    final String raw = v.toStringAsFixed(0);
    if (raw.length <= 3) return raw;
    final String last3 = raw.substring(raw.length - 3);
    final String rest = raw.substring(0, raw.length - 3);
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StudentWiseYearlyReportController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        toolbarHeight: 70.h,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Student Wise Yearly Report',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GetX<StudentWiseYearlyReportController>(
        builder: (ctrl) {
          return Column(
            children: [
              // ── Scrollable content ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Search Card ──────────────────────────────────
                      _searchCard(ctrl),
                      SizedBox(height: 20.h),

                      // ── Summary Cards ────────────────────────────────
                      if (ctrl.isSearched.value &&
                          ctrl.reportList.isNotEmpty) ...[
                        _summaryCards(ctrl),
                        SizedBox(height: 20.h),
                      ],

                      // ── Error / Empty ────────────────────────────────
                      if (ctrl.isSearched.value &&
                          ctrl.errorMessage.value.isNotEmpty)
                        _emptyState(ctrl.errorMessage.value),

                      // ── Table ────────────────────────────────────────
                      if (ctrl.isSearched.value &&
                          ctrl.reportList.isNotEmpty)
                        _tableCard(ctrl),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Search card ──────────────────────────────────────────────────────────
  Widget _searchCard(StudentWiseYearlyReportController ctrl) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session label
          Row(
            children: [
              Text(
                'Session ',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2847),
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Session Dropdown
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
            ),
            child: ctrl.isSessionLoading.value
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00695C),
                  strokeWidth: 2,
                ),
              ),
            )
                : DropdownButtonHideUnderline(
              child: DropdownButton<sListDdata>(
                value: ctrl.selectedSession.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1A2847),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A2847),
                ),
                items: ctrl.sessionList
                    .map(
                      (s) => DropdownMenuItem<sListDdata>(
                    value: s,
                    child: Text(s.session ?? ''),
                  ),
                )
                    .toList(),
                onChanged: ctrl.onSessionChanged,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Search Button
          GestureDetector(
            onTap: ctrl.isLoading.value ? null : ctrl.search,
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ctrl.isLoading.value
                  ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                'Load Data',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary cards row (2 per row grid) ──────────────────────────────────
  Widget _summaryCards(StudentWiseYearlyReportController ctrl) {
    final cards = _buildCards(ctrl);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, i) => _SummaryCard(data: cards[i]),
    );
  }

  // ── Table card ───────────────────────────────────────────────────────────
  Widget _tableCard(StudentWiseYearlyReportController ctrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + Download/Share buttons ───────────────────────────
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Student Fee List',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A2847),
                    ),
                  ),
                ),

                // ── Download PDF button ──────────────────────────────
                ctrl.isPdfGenerating.value
                    ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    color: Color(0xFF00695C),
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  children: [
                    // Download button
                    Tooltip(
                      message: 'Download PDF',
                      child: InkWell(
                        onTap: ctrl.downloadPdf,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0)
                                .withOpacity(0.10),
                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: const Color(0xFF1565C0),
                            size: 22.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // Share button
                    Tooltip(
                      message: 'Share PDF',
                      child: InkWell(
                        onTap: ctrl.sharePdf,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00695C)
                                .withOpacity(0.10),
                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.share_rounded,
                            color: const Color(0xFF00695C),
                            size: 22.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200, thickness: 1),

          // Horizontal + vertical scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 420.h,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                      const Color(0xFF004D40)),
                  headingTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                  dataRowMinHeight: 46.h,
                  dataRowMaxHeight: 54.h,
                  columnSpacing: 16.w,
                  horizontalMargin: 14.w,
                  dividerThickness: 0.5,
                  columns: [
                    _col('S.No'),
                    _col('Reg. No'),
                    _col('Student Name'),
                    _col('Father Name'),
                    _col('Class'),
                    _col('Section'),
                    _col('Total Fee Assign'),
                    _col('Total Discount Given'),
                    _col('Net Collected'),
                    _col('Paid'),
                    _col('Due'),
                  ],
                  rows: [
                    // Data rows
                    ...List.generate(ctrl.reportList.length, (index) {
                      final item = ctrl.reportList[index];
                      final isEven = index % 2 == 0;
                      return DataRow(
                        color: MaterialStateProperty.all(
                          isEven
                              ? Colors.white
                              : const Color(0xFFF0F9F8),
                        ),
                        cells: [
                          _cell('${item.sNo}'),
                          _cell(item.registrationNo),
                          _cell(item.studentName),
                          _cell(item.fatherName),
                          _cell(item.className),
                          _cell(item.section),
                          _amtCell(item.totalFee),
                          _amtCell(item.totalDiscount),
                          _amtCell(item.netFee),
                          _amtCell(item.totalPaid),
                          _dueCell(item.totalDue),
                        ],
                      );
                    }),

                    // ── Totals row ───────────────────────────────────
                    DataRow(
                      color: MaterialStateProperty.all(
                          const Color(0xFF004D40)),
                      cells: [
                        _totalLabelCell('Total'),
                        _totalLabelCell(''),
                        _totalLabelCell(''),
                        _totalLabelCell(''),
                        _totalLabelCell(''),
                        _totalLabelCell(''),
                        _totalAmtCell(ctrl.sumTotalFee),
                        _totalAmtCell(ctrl.sumTotalDiscount),
                        _totalAmtCell(ctrl.sumNetFee),
                        _totalAmtCell(ctrl.sumTotalPaid),
                        _totalAmtCell(ctrl.sumTotalDue,
                            isDue: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────
  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48.r, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
            TextStyle(fontSize: 15.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Column helpers ────────────────────────────────────────────────────────
  DataColumn _col(String label) => DataColumn(label: Text(label));

  DataCell _cell(String value) => DataCell(
    Text(
      value,
      style: TextStyle(
          fontSize: 11.sp, color: const Color(0xFF1A2847)),
    ),
  );

  DataCell _amtCell(double value) => DataCell(
    Text(
      '₹ ${value.toStringAsFixed(0)}',
      style: TextStyle(
          fontSize: 11.sp, color: const Color(0xFF1A2847)),
    ),
  );

  DataCell _dueCell(double value) => DataCell(
    Text(
      '₹ ${value.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 11.sp,
        color: value > 0
            ? Colors.red.shade700
            : Colors.green.shade700,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // ── Totals row helpers ───────────────────────────────────────────────────
  DataCell _totalLabelCell(String text) => DataCell(
    Text(
      text,
      style: TextStyle(
        fontSize: 11.sp,
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  DataCell _totalAmtCell(double value, {bool isDue = false}) => DataCell(
    Text(
      '₹ ${value.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 11.sp,
        color: isDue
            ? (value > 0
            ? Colors.orange.shade200
            : Colors.green.shade200)
            : Colors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

// ── Summary Card widget ───────────────────────────────────────────────────

class _CardData {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final bool isAmount;

  const _CardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isAmount,
  });
}

class _SummaryCard extends StatelessWidget {
  final _CardData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.icon,
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.isAmount ? '₹ ${data.value}' : data.value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}