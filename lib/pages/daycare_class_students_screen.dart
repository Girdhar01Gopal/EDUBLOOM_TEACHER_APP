import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:teacher_app_edubloom/pages/studentdaycardetails.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/daycareaddstudentmodel.dart';


const _teal = Color(0xFF00695C);
const _tealLight = Color(0xFF26A69A);
const _surface = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);

class DaycareClassStudentsScreen extends StatefulWidget {
  final String className;
  final bool showAll;
  const DaycareClassStudentsScreen({
    super.key,
    required this.className,
    this.showAll = false,
  });
  @override
  State<DaycareClassStudentsScreen> createState() =>
      _DaycareClassStudentsScreenState();
}

class _DaycareClassStudentsScreenState
    extends State<DaycareClassStudentsScreen> {
  List<DaycareStudentData> classStudents = [];
  List<DaycareStudentData> filteredStudents = [];
  bool isLoading = false;
  String schoolId = '';
  String session = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    schoolId =
        await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    session =
        await PrefManager().readValue(key: PrefConst.session) ?? '';
    await _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        'https://playschool.edubloom.in/api/StudentApp/GetAllDaycareStudentsAsyncApp'
            '?schoolId=$schoolId&currentSession=$session',
      );
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final students = DaycareStudentResponse.fromJson(jsonResponse);
        final all = students.data;

        classStudents = widget.showAll
            ? all
            : all
            .where((s) =>
        (s.className ?? '').trim().toLowerCase() ==
            widget.className.trim().toLowerCase())
            .toList();
        filteredStudents = List.from(classStudents);
      }
    } catch (e) {
      debugPrint("_loadStudents daycare error => $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _search(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        filteredStudents = List.from(classStudents);
      } else {
        filteredStudents = classStudents.where((s) {
          return (s.studentName?.toLowerCase().contains(q) ?? false) ||
              (s.phone?.toLowerCase().contains(q) ?? false) ||
              (s.fatherName?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Text(
              widget.showAll
                  ? '${classStudents.length} Total Daycare Students'
                  : '${classStudents.length} Daycare Students',
              style:
              const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: _teal,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _search,
                style:
                TextStyle(fontSize: 14.sp, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by name, phone...',
                  hintStyle: TextStyle(
                      color: _textSecondary, fontSize: 13.sp),
                  prefixIcon:
                  const Icon(Icons.search, color: _tealLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                ),
              ),
            ),
          ),

          // Count row
          Container(
            color: _teal.withOpacity(0.07),
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.child_care, size: 16, color: _teal),
                SizedBox(width: 6.w),
                Text(
                  'Showing: ${filteredStudents.length} of ${classStudents.length}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _teal,
                  ),
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
                    'Active: ${classStudents.where((s) => (s.action ?? '').trim() == '1' || (s.action ?? '').trim().toLowerCase() == 'active').length}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
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
                    'Inactive: ${classStudents.where((s) => (s.action ?? '').trim() == '0' || (s.action ?? '').trim().toLowerCase() == 'inactive').length}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: _teal))
                : filteredStudents.isEmpty
                ? _emptyState()
                : RefreshIndicator(
              color: _teal,
              onRefresh: _loadStudents,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 12.h),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) =>
                    _daycareCard(filteredStudents[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care,
              size: 64, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'No daycare students in ${widget.className}',
            style: TextStyle(
                color: _textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _daycareCard(DaycareStudentData s) {
    final isActive = (s.action ?? '').trim().toLowerCase() == '1' ||
        (s.action ?? '').trim().toLowerCase() == 'active';
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 68.w,
                    width: 68.w,
                    color: Colors.teal.shade50,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 36.w,
                        color: _tealLight,
                      ),
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
                      border: Border.all(
                          color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.studentName ?? '-',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _infoRow(Icons.person_outline,
                      'Father: ${s.fatherName ?? '-'}'),
                  _infoRow(Icons.wc_outlined,
                      'Gender: ${s.gender ?? '-'}'),
                  _infoRow(
                      Icons.phone_outlined, s.phone ?? '-'),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(20.r),
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
                      GestureDetector(
                        onTap: () => Get.to(() =>
                            StudentDetailScreenday(student: s)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_tealLight, _teal]),
                            borderRadius:
                            BorderRadius.circular(20.r),
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
                    ],
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