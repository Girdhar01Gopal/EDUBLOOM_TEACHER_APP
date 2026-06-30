import 'package:get/get.dart';
import '../controller/student_wise_yearly_report_controller.dart';

class StudentWiseYearlyReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentWiseYearlyReportController>(
          () => StudentWiseYearlyReportController(),
    );
  }
}