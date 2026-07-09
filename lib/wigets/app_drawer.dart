import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../controller/appdrawercontroller.dart';
import '../controller/home_page_controller.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../res/app_url.dart';
import '../utils/constans.dart';

class AppDrawer extends GetView<Appdrawercontroller> {
  Appdrawercontroller controller = Get.put(Appdrawercontroller());
  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardScreenController());

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ---------- HEADER ----------
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5E0E29),
                    Color(0xFF8F1542),
                    Colors.white,
                  ],
                ),
              ),
              child: Obx(
                    () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SCHOOL LOGO
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        '${AppUrl.dashurl}/${Get.find<DashboardScreenController>().schoollogo.value}',
                        height: 60.h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 60.h,
                          width: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // SCHOOL NAME
                    Text(
                      Get.find<DashboardScreenController>().schoollname.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- MENU LIST ----------
            Expanded(
              child: Obx(
                    () => ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: controller.vehicleDocumentList.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    var item = controller.vehicleDocumentList[index];

                    return InkWell(
                      onTap: () {
                        controller.onSelectedBottom(index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 14.w),
                        child: Row(
                          children: [
                            // ── Colored Icon Circle ──
                            Container(
                              height: 45.h,
                              width: 45.w,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: item.bgColor, // unique bg per item
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.image,
                                color: item.color, // unique icon color per item
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 15.w),

                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ---------- LOGOUT BUTTON ----------
            Container(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await PrefManager()
                      .writeValue(key: PrefConst.isLoggedIn, value: "No");
                  await PrefManager().clearPref();
                  Get.offAllNamed(RouteName.login_screen);
                  Get.snackbar("Logout", "Teacher logged out successfully");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}