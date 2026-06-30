import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../pages/homepage.dart';
import '../utils/constans.dart';

class LoginCard extends StatelessWidget {
  bool passwordInvisible = true;

  LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.only(
        bottom: 10.h,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, 15.0),
                blurRadius: 15.0.r),
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, -10.0),
                blurRadius: 15.0.r),
          ]),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0.w,
          right: 16.0.w,
          top: 40.0.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Parent Id",
                style: TextStyle(fontFamily: "Poppins", fontSize: 20.sp)),
            TextField(
              decoration: InputDecoration(
                  hintText: "Parent Id",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0.sp)),
            ),
            SizedBox(
              height: 10.h,
            ),
            Text("Password",
                style: TextStyle(fontFamily: "Poppins", fontSize: 20.sp)),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "**********",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0.sp)),
            ),
            SizedBox(
              height: 25.h,
            ),
            Center(
              child: Container(
                width: 130.w,
                height: 40.h,
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(6.0.r),
                    boxShadow: [
                      BoxShadow(
                          color: ActiveShadowColor,
                          offset: const Offset(0.0, 8.0),
                          blurRadius: 8.0.r)
                    ]),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Dhashoard()));
                  },
                  child: Center(
                    child: Text("SIGN IN",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins-Bold",
                            fontSize: 16.sp,
                            letterSpacing: 1.0.w)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            )
          ],
        ),
      ),
    );
  }
}
