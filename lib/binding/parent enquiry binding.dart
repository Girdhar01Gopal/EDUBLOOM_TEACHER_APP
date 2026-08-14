import 'package:get/get.dart';

import '../controller/parent enquiry controller.dart';

class ParentEnquiryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnquiryController>(() => EnquiryController());
  }
}