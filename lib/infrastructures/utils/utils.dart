// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// class Utils{
//   static void  fieldFocusChange(BuildContext context, FocusNode current, FocusNode nextFocus){
//     current.unfocus();
//     FocusScope.of(context).requestFocus(nextFocus);
//   }

// }
class ShortMessage {
  static toast({required String title}) {
    return Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static snackBar(
      {required String title, int? duration = 60, required String message}) {
    return Get.showSnackbar(GetSnackBar(
        title: title,
        message: message,
        duration: Duration(seconds: duration!)));
  }
}

// // class UrlLauncher {
// //   launchUri({required String url, required LaunchMode mode}) async {
// //     if (!await launchUrl(Uri.parse(url),
// //         mode: LaunchMode.externalApplication)) {
// //       throw Exception('Could not launch $url');
// //     }
// //   }
// // }
