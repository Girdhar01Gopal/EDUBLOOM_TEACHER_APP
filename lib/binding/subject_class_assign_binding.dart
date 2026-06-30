import 'package:get/get.dart';

import '../controller/subject_class_assign_controller.dart';

class SubjectClassAssignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectClassAssignController>(() => SubjectClassAssignController());
  }
}