import 'package:get/get.dart';
import '../controller/teacher_subject_controller.dart';

class TeacherSubjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherSubjectController>(() => TeacherSubjectController());
  }
}