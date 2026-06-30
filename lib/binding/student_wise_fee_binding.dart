import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../controller/student_wise_fee_controller.dart';

class StudentWiseFeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentWiseFeeController>(() => StudentWiseFeeController());
  }
}