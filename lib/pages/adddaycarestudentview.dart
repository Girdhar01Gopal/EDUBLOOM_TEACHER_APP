import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teacher_app_edubloom/pages/studentdaycardetails.dart';

import 'package:url_launcher/url_launcher.dart';

import '../controller/student_controller daycare.dart' as daycare_controller;
import 'nextdaycare.dart';

// ─── Palette ───────────────────────────────────────────────
const _teal = Color(0xFF00695C);
const _tealLight = Color(0xFF26A69A);
const _surface = Color(0xFFFFFFFF);
const _cardBg = Color(0xFFF8FFFE);
const _textPrimary = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);
const _divider = Color(0xFFE0F2F1);

// ═══════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════
class StudentScreen2
    extends GetView<daycare_controller.StudentControllerdaycare> {
  daycare_controller.StudentControllerdaycare controller =
  Get.put(daycare_controller.StudentControllerdaycare());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: _buildAppBar(),
        body: const TabBarView(
          children: [
            AddDaycareStudentTab(),
            ViewDaycareStudentTab(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _teal,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('🎓', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          const Text(
            'Student Day Care',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: TabBar(
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle:
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(
              icon: Icon(Icons.person_add_alt_1, size: 20),
              text: 'Add Student'),
          Tab(
              icon: Icon(Icons.people_alt_outlined, size: 20),
              text: 'View Students'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ADD DAYCARE STUDENT TAB
// ═══════════════════════════════════════════════════════════
class AddDaycareStudentTab
    extends GetView<daycare_controller.StudentControllerdaycare> {
  const AddDaycareStudentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Basic Information', Icons.person_outline),
            _buildCard([
              _inputField('Student Name', controller.studentName,
                  required: true, icon: Icons.badge_outlined),
              _genderDropdown(controller),
              _dobPicker(context),
              _bloodgroupDropdown(controller),
              _inputField('Religion', controller.religion,
                  icon: Icons.temple_hindu_outlined),
              _emailField(),
            ]),
            SizedBox(height: 24.h),
            _saveButton(context),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _teal),
          SizedBox(width: 6.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _teal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _saveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF00695C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: _teal.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          label: Text(
            'Save & Next',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
          onPressed: () {
            if (controller.formKey.currentState?.validate() ?? false) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => Nextdaycare()));
            } else {
              Get.snackbar("⚠️ Validation Error", "Please fill required fields");
            }
          },
        ),
      ),
    );
  }

  Widget _inputField(String label, RxString rxValue,
      {bool required = false, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        onChanged: (v) => rxValue.value = v,
        decoration: _inputDeco(label, icon: icon, required: required),
        validator: (v) =>
        required && (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller.emailController,
        onChanged: (v) => controller.email.value = v,
        keyboardType: TextInputType.emailAddress,
        decoration: _inputDeco('Email', icon: Icons.email_outlined),
        validator: (v) {
          if (v != null && v.isNotEmpty) {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
              return 'Invalid email';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _dobPicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(primary: _teal)),
            child: child!,
          ),
        );
        if (picked != null) {
          String date = picked.toIso8601String().split('T').first;
          controller.dateOfBirth.value = date;
          controller.dob.text = date;
        }
      },
      child: AbsorbPointer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: TextFormField(
            controller: controller.dob,
            decoration: _inputDeco('Date of Birth',
                icon: Icons.calendar_today_outlined, required: true),
            validator: (v) =>
            (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      ),
    );
  }

  Widget _genderDropdown(
      daycare_controller.StudentControllerdaycare controller) {
    const genderOptions = ["Boy", "Girl", "Other"];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        String? selected = controller.gender.value.trim().isEmpty
            ? null
            : controller.gender.value.trim();
        if (!genderOptions.contains(selected)) selected = null;
        return DropdownButtonFormField<String>(
          value: selected,
          items: genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => controller.gender.value = v ?? "",
          decoration:
          _inputDeco('Gender', icon: Icons.wc_outlined, required: true),
          validator: (v) => v == null ? 'Required' : null,
        );
      }),
    );
  }

  Widget _bloodgroupDropdown(
      daycare_controller.StudentControllerdaycare controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        return DropdownButtonFormField<String>(
          value: controller.bloodGroup.value.isEmpty
              ? null
              : controller.bloodGroup.value,
          items: ["A-", "A+", "B-", "B+", "O-", "O+"]
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => controller.bloodGroup.value = v!,
          decoration:
          _inputDeco('Blood Group', icon: Icons.bloodtype_outlined),
        );
      }),
    );
  }

  InputDecoration _inputDeco(String label,
      {IconData? icon, bool required = false}) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      labelStyle: TextStyle(color: _textSecondary, fontSize: 14.sp),
      prefixIcon:
      icon != null ? Icon(icon, size: 20, color: _tealLight) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _teal, width: 1.5),
      ),
      filled: true,
      fillColor: _cardBg,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// VIEW DAYCARE STUDENT TAB
// ═══════════════════════════════════════════════════════════
class ViewDaycareStudentTab extends StatefulWidget {
  const ViewDaycareStudentTab({super.key});

  @override
  State<ViewDaycareStudentTab> createState() =>
      _ViewDaycareStudentTabState();
}

class _ViewDaycareStudentTabState extends State<ViewDaycareStudentTab>
    with SingleTickerProviderStateMixin {
  final controller =
  Get.find<daycare_controller.StudentControllerdaycare>();
  late TabController _innerTabController;

  static const String _studentBase =
      "https://playschool.edubloom.in/Upload/student/images/";

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
    controller.fetchVStudents();
  }

  @override
  void dispose() {
    _innerTabController.dispose();
    super.dispose();
  }

  String? _buildImageUrl(String? file) {
    if (file == null) return null;
    final f = file.trim();
    if (f.isEmpty) return null;
    if (f.startsWith('http')) return f;
    return "$_studentBase$f";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar (top padding added) ──────────────
        Container(
          color: _teal,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: TextField(
              onChanged: controller.filterStudents,
              style: TextStyle(fontSize: 14.sp, color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, ID, reg no, phone...',
                hintStyle:
                TextStyle(color: _textSecondary, fontSize: 13.sp),
                prefixIcon:
                const Icon(Icons.search, color: _tealLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
              ),
            ),
          ),
        ),

        // ── Active / Inactive inner TabBar ──────────────
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _innerTabController,
            labelColor: _teal,
            unselectedLabelColor: _textSecondary,
            indicatorColor: _teal,
            indicatorWeight: 3,
            labelStyle:
            TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(
                icon: Icon(Icons.check_circle_outline,
                    size: 18, color: Color(0xFF43A047)),
                text: 'Active',
              ),
              Tab(
                icon: Icon(Icons.cancel_outlined,
                    size: 18, color: Colors.redAccent),
                text: 'Inactive',
              ),
            ],
          ),
        ),

        // ── Inner TabBarView ────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: _teal));
            }

            final activeList = controller.filteredData
                .where((s) =>
            (s.action ?? '').trim().toLowerCase() == '1' ||
                (s.action ?? '').trim().toLowerCase() == 'active')
                .toList();

            final inactiveList = controller.filteredData
                .where((s) =>
            (s.action ?? '').trim().toLowerCase() == '0' ||
                (s.action ?? '').trim().toLowerCase() == 'inactive')
                .toList();

            return TabBarView(
              controller: _innerTabController,
              children: [
                // Active
                activeList.isEmpty
                    ? _emptyState('No active students')
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  itemCount: activeList.length,
                  itemBuilder: (context, index) =>
                      _daycareCard(activeList[index], context),
                ),
                // Inactive
                inactiveList.isEmpty
                    ? _emptyState('No inactive students')
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  itemCount: inactiveList.length,
                  itemBuilder: (context, index) =>
                      _daycareCard(inactiveList[index], context),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(msg,
              style: TextStyle(
                  color: _textSecondary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _daycareCard(dynamic s, BuildContext context) {
    final isActive =
        (s.action ?? '').toString().trim().toLowerCase() == '1' ||
            (s.action ?? '').toString().trim().toLowerCase() == 'active';
    final imageUrl = _buildImageUrl(s.studentPic);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 68.w,
                    width: 68.w,
                    color: Colors.teal.shade50,
                    child: (imageUrl != null)
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 36.w,
                          color: _tealLight),
                    )
                        : Icon(Icons.person,
                        size: 36.w, color: _tealLight),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF43A047)
                          : Colors.red.shade400,
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),

            // ── Info ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Name only — empty dot container removed
                  Text(
                    s.studentName ?? '-',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  _infoRow(Icons.wc_outlined,
                      'Gender: ${s.gender ?? '-'}'),

                  // ✅ Phone — tappable, no underline
                  GestureDetector(
                    onTap: () async {
                      final phone = (s.phone ?? '').toString().trim();
                      if (phone.isNotEmpty && phone != '-') {
                        final uri = Uri(scheme: 'tel', path: phone);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 12, color: Colors.teal.shade600),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              (s.phone ?? '-').toString(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.teal.shade700,
                                height: 1.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // ── View Details button ──────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.to(
                              () => StudentDetailScreenday(student: s)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_tealLight, _teal]),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF455A64)),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF37474F),
                  height: 1.4),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}