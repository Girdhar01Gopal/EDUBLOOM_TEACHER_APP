import 'package:get/get.dart';

import '../controller/view_teacher_attendance_controller.dart';

class ViewTeacherAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewTeacherAttendanceController>(() => ViewTeacherAttendanceController());
  }
}