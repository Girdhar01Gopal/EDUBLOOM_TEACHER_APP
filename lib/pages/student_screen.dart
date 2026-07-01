import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teacher_app_edubloom/pages/studentdetialsview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/student_controller.dart';
import '../models/sectionmodel.dart';
import '../models/routeno.dart';
import '../models/student_model.dart';
import 'id_card_print_screen.dart';
import 'next_screen.dart';

// ─── Palette ───────────────────────────────────────────────
const _teal = Color(0xFF97144D);
const _tealLight = Color(0xFFC2185B);
const _accent = Color(0xFFFF6B6B);
const _cardBg = Color(0xFFF8FFFE);
const _surface = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);
const _divider = Color(0xFFE0F2F1);

class StudentScreen extends GetView<StudentController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: _buildAppBar(),
        body: const TabBarView(
          children: [
            AddStudentTab(),
            ViewStudentTab(),
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
          Container(padding: const EdgeInsets.all(6)),
          const SizedBox(width: 10),
          const Text(
            '🎓 Pre School Students  ',
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
// ADD STUDENT TAB
// ═══════════════════════════════════════════════════════════
class AddStudentTab extends GetView<StudentController> {
  const AddStudentTab({super.key});

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
              // ── Roll No: numbers only ──────────────────
              _inputField(
                'Roll No.',
                controller.rollNo,
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                rollNoValidation: true,
              ),
              _inputField(
                'Aadhar No.',
                controller.aAdharNo,
                icon: Icons.credit_card_outlined,
                maxLength: 12,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              _genderDropdown(controller),
              _dobPicker(context),
              _bloodgroup(controller),
              _inputField('Religion', controller.religion,
                  icon: Icons.temple_hindu_outlined),
              _emailField(),
            ]),
            SizedBox(height: 16.h),
            _sectionHeader('Academic Details', Icons.school_outlined),
            _buildCard([
              // ── Select Class dropdown (always visible) ─
              _classDropdown(),
              SizedBox(height: 4.h),
              // ── Select Section dropdown (always visible) ─
              _sectionDropdown(),
              _inputField('Address', controller.address,
                  icon: Icons.location_on_outlined),
              // ── Add Daycare Student: default "No" ──────
              _addDaycareStudentDropdown(),
            ]),
            SizedBox(height: 16.h),
            _sectionHeader(
                'Transport Details', Icons.directions_bus_outlined),
            _buildCard([
              _transportUserDropdown(),
              Obx(() {
                if (controller.transportUser.value == 'Yes') {
                  return Column(
                      children: [_routeNoDropdown(), _stoppageDropdown()]);
                }
                return const SizedBox.shrink();
              }),
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
          Text(title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _teal,
                letterSpacing: 0.5,
              )),
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
              offset: const Offset(0, 2)),
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
            colors: [Color(0xFFC2185B), Color(0xFF97144D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: _teal.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4)),
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
          label: Text('Save & Next',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          onPressed: () {
            if (controller.formKey.currentState!.validate()) {
              if (controller.selectedClass.value == null) {
                Get.snackbar('Error', 'Please select a class.',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              if (controller.selectedSection.value == null) {
                Get.snackbar('Error', 'Please select a section.',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NextStudent()));
            }
          },
        ),
      ),
    );
  }

  // ── Add Daycare Student: default value = "No" ────────────
  Widget _addDaycareStudentDropdown() {
    // Set default to "No" if empty
    if (controller.addDaycareStudent.value.isEmpty) {
      controller.addDaycareStudent.value = 'No';
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        return DropdownButtonFormField<String>(
          value: controller.addDaycareStudent.value.isEmpty
              ? 'No'
              : controller.addDaycareStudent.value,
          items: ["Yes", "No"]
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => controller.addDaycareStudent.value = v!,
          decoration: _inputDeco('Add Daycare Student',
              icon: Icons.child_care_outlined, required: true),
        );
      }),
    );
  }

  Widget _inputField(
      String label,
      RxString rxValue, {
        bool required = false,
        IconData? icon,
        int? maxLength,
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
        bool rollNoValidation = false, // ← new flag for Roll No.
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        onChanged: (v) => rxValue.value = v,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration:
        _inputDeco(label, icon: icon, required: required).copyWith(
          counterText: '',
        ),
        validator: (v) {
          if (required && (v == null || v.isEmpty)) return 'Required';
          // Roll No: must be digits only
          if (rollNoValidation && v != null && v.isNotEmpty) {
            if (!RegExp(r'^\d+$').hasMatch(v)) {
              return 'Roll No. must contain numbers only';
            }
          }
          if (label == 'Aadhar No.' &&
              v != null &&
              v.isNotEmpty &&
              v.length != 12) {
            return 'Aadhar number must be 12 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          final email = v?.trim() ?? '';
          if (email.isEmpty) return null;
          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
            return 'Email must be a valid @gmail.com address';
          }
          return null;
        },
        decoration: _inputDeco('Email', icon: Icons.email_outlined),
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

  Widget _bloodgroup(StudentController controller) {
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

  Widget _genderDropdown(StudentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        return DropdownButtonFormField<String>(
          value: controller.gender.value.isEmpty
              ? null
              : controller.gender.value,
          items: ["Boy", "Girl", "Other"]
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => controller.gender.value = v!,
          decoration: _inputDeco('Gender',
              icon: Icons.wc_outlined, required: true),
          validator: (v) => v == null ? 'Required' : null,
        );
      }),
    );
  }

  Widget _transportUserDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        return DropdownButtonFormField<String>(
          value: controller.transportUser.value.isEmpty
              ? null
              : controller.transportUser.value,
          items: ["Yes", "No"]
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => controller.transportUser.value = v!,
          decoration: _inputDeco('Transport User',
              icon: Icons.directions_bus_outlined, required: true),
        );
      }),
    );
  }

  Widget _routeNoDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        return DropdownButtonFormField<RouteData>(
          value: controller.routes.isNotEmpty
              ? controller.routes.first
              : null,
          onChanged: (v) {
            if (v != null) {
              controller.routeNo.value = v.routeNo.toString();
              controller.fetchPickupPoints(v.routeNo);
            }
          },
          items: controller.routes.map((r) {
            return DropdownMenuItem<RouteData>(
              value: r,
              child: Text("Route ${r.routeNo} | Bus: ${r.busNo}"),
            );
          }).toList(),
          decoration:
          _inputDeco('Route No.', icon: Icons.route_outlined),
        );
      }),
    );
  }

  Widget _stoppageDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Obx(() {
        if (controller.stoppageList.isEmpty) {
          return Text("No stoppages available",
              style:
              TextStyle(color: Colors.red.shade400, fontSize: 13.sp));
        }
        if (!controller.stoppageList.contains(controller.stoppage.value)) {
          controller.stoppage.value = '';
        }
        return DropdownButtonFormField<String>(
          value: controller.stoppage.value.isEmpty
              ? null
              : controller.stoppage.value,
          onChanged: (v) {
            if (v != null) controller.stoppage.value = v;
          },
          items: controller.stoppageList
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          decoration:
          _inputDeco('Stoppage', icon: Icons.place_outlined),
        );
      }),
    );
  }

  // ── Select Class dropdown (always visible, no toggle) ─────
  Widget _classDropdown() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: DropdownButtonFormField<ClassItem>(
          value: controller.selectedClass.value,
          hint: const Text("Select Class"),
          isExpanded: true,
          onChanged: (v) => controller.selectedClass.value = v,
          items: controller.classes
              .map((c) =>
              DropdownMenuItem(value: c, child: Text(c.className)))
              .toList(),
          decoration: _inputDeco('Select Class',
              icon: Icons.class_outlined, required: true),
          validator: (v) => v == null ? 'Please select a class' : null,
        ),
      );
    });
  }

  // ── Select Section dropdown (always visible, no toggle) ───
  Widget _sectionDropdown() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: DropdownButtonFormField<ListDatta>(
          value: controller.selectedSection.value,
          hint: const Text("Select Section"),
          isExpanded: true,
          onChanged: (v) => controller.selectedSection.value = v,
          items: controller.sectionList
              .map((s) => DropdownMenuItem(
              value: s, child: Text(s.section ?? 'No section')))
              .toList(),
          decoration: _inputDeco('Select Section',
              icon: Icons.group_outlined, required: true),
          validator: (v) => v == null ? 'Please select a section' : null,
        ),
      );
    });
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
// VIEW STUDENT TAB
// ═══════════════════════════════════════════════════════════
class ViewStudentTab extends StatefulWidget {
  const ViewStudentTab({super.key});

  @override
  State<ViewStudentTab> createState() => _ViewStudentTabState();
}

class _ViewStudentTabState extends State<ViewStudentTab>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<StudentController>();
  late TabController _innerTabController;

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _teal,
      onRefresh: () async => controller.fetchVStudents(),
      child: Column(
        children: [
          // ── Search bar ──────────────────────────────────
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

          // ── Count badge ────────────────────────────────
          Obx(() => Container(
            color: _teal.withOpacity(0.07),
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.people_alt_outlined,
                    size: 16, color: _teal),
                SizedBox(width: 6.w),
                Text(
                  'Total: ${controller.filteredData.length}',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _teal),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Active: ${controller.filteredData.where((s) => (s.action ?? '').trim().toLowerCase() == '1' || (s.action ?? '').trim().toLowerCase() == 'active').length}',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Inactive: ${controller.filteredData.where((s) => (s.action ?? '').trim().toLowerCase() == '0' || (s.action ?? '').trim().toLowerCase() == 'inactive').length}',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          )),

          // ── Active / Inactive inner TabBar ─────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _innerTabController,
              labelColor: _teal,
              unselectedLabelColor: _textSecondary,
              indicatorColor: _teal,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w700),
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

          // ── Inner TabBarView ───────────────────────────
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
                        _studentCard(activeList[index], context),
                  ),
                  // Inactive
                  inactiveList.isEmpty
                      ? _emptyState('No inactive students')
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    itemCount: inactiveList.length,
                    itemBuilder: (context, index) =>
                        _studentCard(inactiveList[index], context),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
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

  Widget _studentCard(StudentData s, BuildContext context) {
    final isActive =
        (s.action ?? '').toString().trim().toLowerCase() == '1' ||
            (s.action ?? '').toString().trim().toLowerCase() == 'active';
    final imageUrl =
        "https://playschool.edubloom.in/Upload/student/images/${s.studentPic ?? ''}";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 68.w,
                    width: 68.w,
                    color: const Color(0xFFF3E5EA),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 36.w,
                          color: _tealLight),
                    ),
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

            // ── Info ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.studentName ?? '-',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary),
                  ),
                  SizedBox(height: 6.h),
                  _infoRow(Icons.person_outline,
                      'Father: ${s.fatherName ?? '-'}'),
                  _infoRow(Icons.class_outlined,
                      '${s.className ?? '-'} | ${s.sectionName ?? '-'}'),

                  // ✅ Phone — tappable
                  GestureDetector(
                    onTap: () async {
                      final phone = s.phone ?? '';
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
                              size: 12, color: _tealLight),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              s.phone ?? '-',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _teal,
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

                  // ── Status + View button ─────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async =>
                            controller.toggleStudentStatus(s),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                color: isActive
                                    ? const Color(0xFF43A047)
                                    : Colors.red.shade400,
                                size: 14,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFF43A047)
                                      : Colors.red.shade400,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(
                                () => StudentDetailScreen(student: s)),
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
                                fontSize: 11.sp),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── 🆕 Print ID Card Button ──────────
                  SizedBox(height: 6.h),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdCardPrintScreen(
                          studentId: s.studentID ?? 0,
                          schoolId: controller.schoolId,
                          currentSession: controller.session.value,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD600).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge_outlined,
                              size: 14, color: Colors.black87),
                          SizedBox(width: 4.w),
                          Text(
                            'Print ID Card',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
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