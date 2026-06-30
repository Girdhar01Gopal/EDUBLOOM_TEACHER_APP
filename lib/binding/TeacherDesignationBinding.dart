import 'package:get/get.dart';
import '../controller/teacher_designation_controller.dart';

class TeacherDesignationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TeacherDesignationController());
  }
}