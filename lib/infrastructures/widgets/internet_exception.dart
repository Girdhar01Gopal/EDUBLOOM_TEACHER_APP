import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InternetExceptionWidget extends StatefulWidget {
  final VoidCallback onPress;

  const InternetExceptionWidget({Key? key, required this.onPress})
      : super(key: key);

  @override
  State<InternetExceptionWidget> createState() =>
      _InternetExceptionWidgetState();
}

class _InternetExceptionWidgetState extends State<InternetExceptionWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: [
          SizedBox(
            height: Get.height * .15,
          ),
          Icon(
            Icons.cloud_off,
            color: Colors.red,
            size: 50.r,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 30.h,
            ),
            child: Center(
              child: Text(
                "Please check your connectivity \n and try again",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: Get.height * .15,
          ),
          InkWell(
            onTap: widget.onPress,
            child: Container(
              height: 44.h,
              width: 160.w,
              decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(50)),
              child: Center(
                child: Text(
                  "Retry",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
