import 'package:get/get.dart';

import '../controller/tc_certificate_controllerdownload.dart';

class TcCertificateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TcCertificateController>(
          () => TcCertificateController(),
    );
  }
}