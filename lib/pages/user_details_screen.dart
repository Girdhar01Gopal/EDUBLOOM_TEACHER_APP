import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/user_details_controller.dart';
import '../models/school_users_all_user_model.dart';
import '../wigets/app_drawer.dart';

class UserDetailsScreen extends GetView<UserDetailsController> {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF97144D),
        elevation: 0,
        toolbarHeight: 70.h,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'School Users',
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF97144D)),
          );
        }
        if (controller.userList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded,
                    size: 64.r, color: Colors.grey.shade400),
                SizedBox(height: 12.h),
                Text(
                  'No users found',
                  style: TextStyle(
                      fontSize: 16.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: _buildTable(context),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: const BoxDecoration(
        color: Color(0xFF6E0F39),
      ),
      child: Row(
        children: [
          Icon(Icons.people_alt_rounded, color: Colors.white70, size: 20.r),
          SizedBox(width: 8.w),
          Text(
            'All Users Data',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Obx(() => Container(
            padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${controller.userList.length} Users',
              style:
              TextStyle(color: Colors.white70, fontSize: 11.sp),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
            MaterialStateProperty.all(const Color(0xFF6E0F39)),
            headingTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
            dataRowMinHeight: 52.h,
            dataRowMaxHeight: 60.h,
            columnSpacing: 20.w,
            horizontalMargin: 16.w,
            dividerThickness: 0.5,
            columns: [
              _col('S.No'),
              _col('Reg No'),
              _col('Role'),
              _col('Name'),
              _col('User Id'),
              _col('Email'),
              _col('Password'),
              _col('Type'),
              _col('Action'),
            ],
            rows: List.generate(controller.userList.length, (index) {
              final SchoolUser user = controller.userList[index];
              final isEven = index % 2 == 0;
              return DataRow(
                color: MaterialStateProperty.all(
                  isEven ? Colors.white : const Color(0xFFF3E0E8),
                ),
                cells: [
                  _cell('${index + 1}'),
                  _cell(user.registrationNo),
                  _roleChip(user.role),
                  _cell('${user.firstName} ${user.lastName ?? ''}'.trim()),
                  _cell(user.userName),
                  _cell(user.email),
                  _passwordCell(user.password),
                  _cell(user.teacherTypeName ?? user.staffTypeName ?? '-'),
                  _actionCell(user),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  DataColumn _col(String label) => DataColumn(
    label: Text(label),
  );

  DataCell _cell(String value) => DataCell(
    Text(
      value,
      style: TextStyle(
          fontSize: 12.sp, color: const Color(0xFF1A2847)),
    ),
  );

  DataCell _roleChip(String role) => DataCell(
    Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: role == 'Teacher'
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11.sp,
          color: role == 'Teacher'
              ? const Color(0xFF1565C0)
              : const Color(0xFF2E7D32),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  DataCell _passwordCell(String password) => DataCell(
    Text(
      password,
      style: TextStyle(
        fontSize: 11.sp,
        color: Colors.grey.shade600,
        fontFamily: 'monospace',
      ),
    ),
  );

  DataCell _actionCell(SchoolUser user) => DataCell(
    GestureDetector(
      onTap: () => controller.goToUserAccess(user.userId),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.remove_red_eye_rounded,
          color: Colors.white,
          size: 18.r,
        ),
      ),
    ),
  );
}