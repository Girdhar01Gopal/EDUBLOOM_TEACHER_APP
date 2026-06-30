// fee_type_report_binding.dart
import 'package:get/get.dart';
import '../controller/FeeTypeReportController.dart';

class FeeTypeReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeeTypeReportController>(() => FeeTypeReportController());
  }
}
