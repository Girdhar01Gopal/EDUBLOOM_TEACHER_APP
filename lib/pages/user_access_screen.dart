import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/user_access_controller.dart';
import '../wigets/app_drawer.dart';

class UserAccessScreen extends StatelessWidget {
  const UserAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserAccessController>();

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
          'User Access',
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GetX<UserAccessController>(
        builder: (ctrl) {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00695C)),
            );
          }

          if (ctrl.modules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 64.r, color: Colors.grey.shade400),
                  SizedBox(height: 12.h),
                  Text(
                    'No access data found',
                    style: TextStyle(
                        fontSize: 16.sp, color: Colors.grey.shade500),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: ctrl.fetchUserAccess,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00695C),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'Retry',
                        style:
                        TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Sub header ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                color: const Color(0xFF004D40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign Access:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ctrl.staffTypeName.value.isNotEmpty
                          ? ctrl.staffTypeName.value
                          : 'User ID: ${ctrl.userId.value}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Modules list ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                  child: Column(
                    children: List.generate(ctrl.modules.length, (mi) {
                      final module = ctrl.modules[mi];
                      final allChecked =
                      module.permissions.every((p) => p.isChecked);
                      final someChecked =
                      module.permissions.any((p) => p.isChecked);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Module header
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4C3),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14.r),
                                  topRight: Radius.circular(14.r),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: Checkbox(
                                      value: allChecked
                                          ? true
                                          : someChecked
                                          ? null
                                          : false,
                                      tristate: true,
                                      activeColor: const Color(0xFF00695C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(4.r),
                                      ),
                                      onChanged: (val) {
                                        ctrl.toggleModule(
                                            mi, val ?? false);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    module.moduleName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A2847),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00695C)
                                          .withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      '${module.permissions.where((p) => p.isChecked).length}/${module.permissions.length}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF00695C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Permissions
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 10.h),
                              child: Wrap(
                                spacing: 8.w,
                                runSpacing: 4.h,
                                children: List.generate(
                                  module.permissions.length,
                                      (pi) {
                                    final perm = module.permissions[pi];
                                    return SizedBox(
                                      width: (MediaQuery.of(context)
                                          .size
                                          .width -
                                          80.w) /
                                          2,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20.w,
                                            height: 20.w,
                                            child: Checkbox(
                                              value: perm.isChecked,
                                              activeColor:
                                              const Color(0xFF00695C),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    3.r),
                                              ),
                                              onChanged: (val) {
                                                ctrl.togglePermission(
                                                    mi, pi, val ?? false);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              perm.name,
                                              style: TextStyle(
                                                fontSize: 11.5.sp,
                                                color: const Color(
                                                    0xFF1A2847),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // ── Bottom bar ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── Refresh icon button (replaces Reset) ──────────
                    GestureDetector(
                      onTap: ctrl.isLoading.value ? null : ctrl.refreshAccess,
                      child: Container(
                        width: 48.h,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2847),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: ctrl.isLoading.value
                              ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // ── Save button ───────────────────────────────────
                    Expanded(
                      child: GestureDetector(
                        onTap: ctrl.isSaving.value ? null : ctrl.saveAccess,
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF59E0B),
                                Color(0xFFFBBF24),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ctrl.isSaving.value
                                ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}