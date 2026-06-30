import 'package:get/get.dart';

import '../controller/View_AttendanceController.dart';
import '../controller/viewdaycareattendancecontroller.dart';

class Viewdaycarebinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Viewdaycareattendancecontroller());
  }
}
