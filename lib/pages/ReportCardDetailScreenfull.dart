import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/home_page_controller.dart';
import '../controller/reportcarddetailcontroller.dart';
import '../models/reportcardinside1.dart';
import '../models/reportcardinside2.dart';
import '../models/reportcardinside3.dart';
import '../models/reportcardinside4.dart';
import '../res/app_url.dart';

// ── Certificate Theme Model ──────────────────────────────────
class _CertTheme {
  final Color headerColor;
  final Color boldTextColor;
  final String label;

  const _CertTheme({
    required this.headerColor,
    required this.boldTextColor,
    required this.label,
  });
}

class ReportCardDetailScreen extends StatefulWidget {
  const ReportCardDetailScreen({super.key});

  @override
  State<ReportCardDetailScreen> createState() => _ReportCardDetailScreenState();
}

class _ReportCardDetailScreenState extends State<ReportCardDetailScreen> {

  // ── Swipeable Themes ─────────────────────────────────────────
  static const List<_CertTheme> _themes = [
    _CertTheme(
      headerColor: Color(0xFF2C3E50),
      boldTextColor: Color(0xFF1A5276),
      label: 'Navy',
    ),
    _CertTheme(
      headerColor: Color(0xFF00695C),
      boldTextColor: Color(0xFF004D40),
      label: 'Teal',
    ),
    _CertTheme(
      headerColor: Color(0xFFF9A825),
      boldTextColor: Color(0xFFF57F17),
      label: 'Yellow',
    ),
    _CertTheme(
      headerColor: Color(0xFFBF360C),
      boldTextColor: Color(0xFFD84315),
      label: 'Sunset Orange',
    ),
    _CertTheme(
      headerColor: Color(0xFF880E4F),
      boldTextColor: Color(0xFFAD1457),
      label: 'Rose Gold',
    ),
  ];

  int _selectedThemeIndex = 0;
  late final PageController _pageController;
  late final ReportCardDetailController controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    controller = Get.find<ReportCardDetailController>();
    controller.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Dynamic school logo URL from DashboardScreenController ───
  String get _dynamicSchoolLogoUrl {
    try {
      final dashCtrl = Get.find<DashboardScreenController>();
      final logoPath = dashCtrl.schoollogo.value;
      if (logoPath.isNotEmpty) {
        return '${AppUrl.dashurl}/$logoPath';
      }
    } catch (_) {}
    return '';
  }

  String _buildStudentImageUrl(String? picName) {
    if (picName == null || picName.isEmpty) return '';
    if (picName.startsWith('http')) return picName;
    return 'https://playschool.edubloom.in/Upload/Student/Images/$picName';
  }

  // ── Theme Dot Indicator ──────────────────────────────────────
  Widget _buildThemeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_themes.length, (i) {
        final isSelected = i == _selectedThemeIndex;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            width: isSelected ? 28.w : 12.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? _themes[i].headerColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(color: _themes[i].headerColor, width: 1.5)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _themes[_selectedThemeIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Report Card",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share',
            onPressed: () => controller.shareReportCard(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: activeTheme.headerColor),
                SizedBox(height: 16.h),
                Text(
                  "Loading Report Card...",
                  style: TextStyle(
                      color: activeTheme.headerColor, fontSize: 14.sp),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Swipe hint label ────────────────────────────
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe, size: 16, color: Colors.grey.shade500),
                  SizedBox(width: 4.w),
                  Text(
                    'Swipe to change theme  •  ${activeTheme.label}',
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // ── Theme dot indicators ────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: _buildThemeDots(),
            ),

            // ── Swipeable report card pages ─────────────────
            Expanded(
              child: RefreshIndicator(
                color: Colors.teal.shade800,
                onRefresh: controller.init,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _themes.length,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedThemeIndex = index;
                      controller.selectedTheme.value = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final theme = _themes[index];
                    final isSelected = index == _selectedThemeIndex;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                      EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                              color: theme.headerColor, width: 2.5)
                              : Border.all(
                              color: Colors.transparent, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? theme.headerColor.withOpacity(0.25)
                                  : Colors.black.withOpacity(0.06),
                              blurRadius: isSelected ? 18 : 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: RepaintBoundary(
                          key: index == _selectedThemeIndex
                              ? controller.repaintKey
                              : null,
                          child: _buildReportCard(theme),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Bottom Buttons ──────────────────────────────
            Container(
              color: Colors.white,
              padding:
              EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.printReportCard(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeTheme.headerColor,
                        padding:
                        EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Print Report Card',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.shareReportCard(),
                      icon: Icon(Icons.picture_as_pdf,
                          color: activeTheme.headerColor, size: 20),
                      label: Text(
                        'Share as PDF',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: activeTheme.headerColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side:
                        BorderSide(color: activeTheme.headerColor),
                        padding:
                        EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Full Report Card ─────────────────────────────────────────
  Widget _buildReportCard(_CertTheme theme) {
    final school      = controller.schoolInfo.value;
    final student     = controller.studentInfo.value;
    final skills      = controller.skillsList;
    final descriptors = controller.descriptorsList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSchoolHeader(theme, school),
        _buildTitleBanner(theme),
        _buildStudentInfo(theme, student),
        if (descriptors.isNotEmpty) ...[
          _buildSectionHeader(
              theme, Icons.menu_book, "Academic Performance"),
          _buildDescriptorsTable(theme, descriptors),
        ],
        if (skills.isNotEmpty) ...[
          _buildSectionHeader(
              theme, Icons.star_rounded, "Foundational Skills"),
          _buildSkillsSection(theme, skills),
        ],
        _buildFooter(theme, school),
      ],
    );
  }

  // ── School Header ────────────────────────────────────────────
  Widget _buildSchoolHeader(_CertTheme theme, ReportCard1Model? school) {
    final logoUrl = _dynamicSchoolLogoUrl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: theme.headerColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipOval(
              child: logoUrl.isNotEmpty
                  ? Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.school,
                  size: 36.sp,
                  color: theme.headerColor,
                ),
              )
                  : Icon(
                Icons.school,
                size: 36.sp,
                color: theme.headerColor,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // School Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school?.schoolName ?? "School Name",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                if (school?.address != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    school!.address!,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.85)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (school?.phone != null) ...[
                  SizedBox(height: 3.h),
                  Row(children: [
                    Icon(Icons.phone, size: 11.sp, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text(school!.phone!,
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.white70)),
                  ]),
                ],
                if (school?.email != null) ...[
                  SizedBox(height: 2.h),
                  Row(children: [
                    Icon(Icons.email, size: 11.sp, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        school!.email!,
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Title Banner ─────────────────────────────────────────────
  Widget _buildTitleBanner(_CertTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: theme.headerColor.withOpacity(0.08),
      child: Center(
        child: Text(
          "★ REPORT CARD  ★",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: theme.boldTextColor,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  // ── Student Info ─────────────────────────────────────────────
  Widget _buildStudentInfo(
      _CertTheme theme, ReportCardInside2Model? student) {
    final imgUrl = _buildStudentImageUrl(student?.studentPic);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.headerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: theme.headerColor.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Student Photo ──
          Container(
            width: 90.w,
            height: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: theme.boldTextColor, width: 2),
              boxShadow: [
                BoxShadow(
                    color: theme.boldTextColor.withOpacity(0.2),
                    blurRadius: 8),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: imgUrl.isNotEmpty
                ? Image.network(
              imgUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: theme.headerColor.withOpacity(0.08),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.boldTextColor,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (_, error, __) {
                debugPrint(
                    "Student pic error: $error | url: $imgUrl");
                return _avatarPlaceholder(theme);
              },
            )
                : _avatarPlaceholder(theme),
          ),
          SizedBox(width: 14.w),

          // ── Student Details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?.studentName ?? "Student Name",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.boldTextColor,
                  ),
                ),
                SizedBox(height: 8.h),
                _infoRow(theme, "Roll No",
                    student?.rollNo ?? "-"),
                _infoRow(theme, "Reg. No",
                    student?.registrationNo ?? "-"),
                //_infoRow(theme, "Admission No",
                   // student?.admissionNo ?? "-"),
                _infoRow(theme, "Session",
                    student?.session ?? controller.session),
                _infoRow(theme, "Term",
                    controller.term.isNotEmpty ? controller.term : "-"),
                _infoRow(theme, "DOB",
                    _formatDate(student?.dob) ?? "-"),
                _infoRow(theme, "Gender",    student?.sex        ?? "-"),
                _infoRow(theme, "Blood Group", student?.bloodGroup ?? "-"),
                _infoRow(theme, "Father",    student?.fatherName  ?? "-"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(_CertTheme theme) {
    return Container(
      color: theme.headerColor.withOpacity(0.08),
      child: Icon(Icons.person,
          size: 50.sp, color: theme.headerColor.withOpacity(0.4)),
    );
  }

  Widget _infoRow(_CertTheme theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 11.sp,
                color: theme.boldTextColor.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────
  Widget _buildSectionHeader(
      _CertTheme theme, IconData icon, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.headerColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Descriptors Table ─────────────────────────────────────────
  Widget _buildDescriptorsTable(
      _CertTheme theme, List<ReportCardInside4Model> descriptors) {
    final Map<String, List<ReportCardInside4Model>> grouped = {};
    for (final d in descriptors) {
      final sub = d.subject ?? "General";
      grouped.putIfAbsent(sub, () => []).add(d);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.headerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.headerColor.withOpacity(0.12),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text("Subject",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: theme.boldTextColor)),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Descriptors",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: theme.boldTextColor)),
                ),
                SizedBox(
                  width: 50.w,
                  child: Text("Grade",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: theme.boldTextColor)),
                ),
              ],
            ),
          ),
          // Data rows
          ...grouped.entries.toList().asMap().entries.map((entry) {
            final idx         = entry.key;
            final subjectName = entry.value.key;
            final items       = entry.value.value;
            final isEven      = idx % 2 == 0;

            return Container(
              color: isEven
                  ? theme.headerColor.withOpacity(0.05)
                  : Colors.white,
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            subjectName,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: theme.boldTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.descriptors ?? "-",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black87),
                          ),
                        ),
                        SizedBox(
                          width: 50.w,
                          child: Center(
                            child: _gradeChip(item.grade ?? "-"),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _gradeChip(String grade) {
    Color chipColor = Colors.grey.shade600;
    if (grade == 'A+' || grade == 'A') chipColor = Colors.green.shade700;
    if (grade == 'B+' || grade == 'B') chipColor = Colors.blue.shade700;
    if (grade == 'C')                  chipColor = Colors.orange.shade700;
    if (grade == 'D')                  chipColor = Colors.red.shade700;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── Skills Section ────────────────────────────────────────────
  Widget _buildSkillsSection(
      _CertTheme theme, List<ReportCardInside3Model> skills) {
    final Map<String, List<ReportCardInside3Model>> grouped = {};
    for (final s in skills) {
      final lvl = s.level ?? "General";
      grouped.putIfAbsent(lvl, () => []).add(s);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Column(
        children: grouped.entries.map((entry) {
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.headerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: theme.headerColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.boldTextColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Level: ${entry.key}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                ...entry.value.map((skill) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 14.sp, color: theme.boldTextColor),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            skill.foundationalSkills ?? "",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────
  Widget _buildFooter(_CertTheme theme, ReportCard1Model? school) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: theme.headerColor.withOpacity(0.06),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Column(
        children: [
          Divider(
              color: theme.headerColor.withOpacity(0.3), thickness: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _signatureBlock(theme, "Class Teacher"),
              _signatureBlock(theme, "Principal"),
              _signatureBlock(theme, "Parent/Guardian"),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            school?.schoolName ?? "",
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.boldTextColor.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signatureBlock(_CertTheme theme, String label) {
    return Column(
      children: [
        Container(
            width: 80.w,
            height: 1,
            color: theme.headerColor.withOpacity(0.5)),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: theme.boldTextColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year}";
    } catch (_) {
      return raw.split('T').first;
    }
  }
}