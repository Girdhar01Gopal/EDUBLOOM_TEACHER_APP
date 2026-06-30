import 'package:get/get.dart';
import '../controller/all_fee_report_controller.dart';

class AllFeeReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AllFeeReportController());
  }
}
