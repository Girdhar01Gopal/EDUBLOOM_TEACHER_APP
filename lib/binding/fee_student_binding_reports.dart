import 'package:get/get.dart';
import '../controller/fee_student_controller_reports.dart';

class FeeStudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeeStudentReportsController>(() => FeeStudentReportsController());
  }
}
