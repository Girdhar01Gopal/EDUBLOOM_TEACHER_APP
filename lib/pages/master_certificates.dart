import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/master_certificate_controller.dart';
import '../controller/master_expenses_controller.dart';
import '../controller/master_product_controller.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/utils/custom_text.dart';
import '../wigets/app_drawer.dart';

class MasterCertificatesscreen extends GetView<MastercertificateController> {
  const MasterCertificatesscreen({super.key});

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
          "Master Certificates ",
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
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
                        color: item.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(14.r),
                      child: Icon(
                        item.icons,
                        size: 34.r,
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