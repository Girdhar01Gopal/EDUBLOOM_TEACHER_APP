import 'package:get/get.dart';

import '../controller/stationary_fee_student_controller.dart';

class StationaryFeeStudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StationaryFeeStudentController>(
          () => StationaryFeeStudentController(),
    );
  }
}