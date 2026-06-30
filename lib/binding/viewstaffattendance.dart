import 'package:get/get.dart';

import '../controller/view_staff_attendance_controller.dart';


class Viewstaffattendance extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => ViewStaffAttendanceController());
  }

}