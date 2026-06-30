import 'package:get/get.dart';
import '../controller/master_certificate_controller.dart';
import '../controller/master_expenses_controller.dart';

class mastercertificatebinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MastercertificateController>(
          () => MastercertificateController(),
    );
  }
}