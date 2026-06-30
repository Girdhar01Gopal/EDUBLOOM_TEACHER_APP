import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/log_out_page_controller.dart';

class LogoutPage extends GetView<LogoutPageController> {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Logout',
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colors.white,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF268ac5),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ))),
      backgroundColor: Colors.grey.shade300,
      body: Container(
        margin:
            EdgeInsets.only(top: 20.h, left: 10.w, right: 10.w, bottom: 10.w),
        height: 165.h,
        width: Get.width,
        decoration: BoxDecoration(
            color: Colors.white, border: Border.all(width: 0.6.w)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    alignment: Alignment.center,
                    height: 30.h,
                    decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(5.r)),
                    child: const Text(
                      "User's Name",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Contact",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 0.6.h,
              color: Colors.black,
            ),
            InkWell(
              onTap: () {},
              child: SizedBox(
                height: 35.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: Colors.green,
                      size: 40.sp,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
