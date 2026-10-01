import 'package:get/get.dart';
import '../controller/all teachers attendance take controller.dart';

class TeacherAttendanceBinding2 extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherAttendanceController2>(
          () => TeacherAttendanceController2(),
      fenix: true,
    );
  }
}