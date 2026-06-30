import 'package:get/get.dart';
import '../controller/teacher_add_controller.dart';

class TeacherAddBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ always create when route opens, and dispose when removed
    Get.lazyPut<TeacherAddController>(() => TeacherAddController(), fenix: false);
  }
}