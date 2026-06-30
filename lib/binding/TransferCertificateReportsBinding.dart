import 'package:get/get.dart';
import '../controller/TransferCertificateReportsController.dart';
import '../controller/View_AttendanceController.dart';

class TransferCertificateReportsbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TransferCertificateReportsController());
  }
}
