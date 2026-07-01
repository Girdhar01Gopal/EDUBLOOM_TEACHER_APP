import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/addstudentcontrollermaster.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/utils/custom_text.dart';
import '../wigets/app_drawer.dart';

class Addstudentmaster extends GetView<Addstudentcontrollermaster> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: AppDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF97144D),
        elevation: 0,
        toolbarHeight: 75.h,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "🎓 Students",
          style: TextStyle(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          // Faded logo background
          Positioned.fill(
            top: 200.h,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                ImageConstants.logo,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Main scroll content
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                _buildDashboardGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Header Card ------------------
  Widget _headerCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Container(
        width: Get.width,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF268ac5), Color(0xFF53B5F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.15),
              blurRadius: 14.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 38.r,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(Icons.person, size: 42.r, color: Colors.white),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Manage everything from one place",
                    style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ Dashboard Grid ------------------
  Widget _buildDashboardGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Obx(() {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.vehicleDocumentList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .95,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            var item = controller.vehicleDocumentList[index];

            return InkWell(
              onTap: () => controller.onSelectedBottom(index),
              borderRadius: BorderRadius.circular(16.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 62.h,
                      width: 62.w,
                      decoration: BoxDecoration(
                        color: item.bgColor,   // ← updated
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.image,
                        size: 28.sp,
                        color: item.color,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    CustomText(
                      data: item.name,
                      fontSize: 15.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}