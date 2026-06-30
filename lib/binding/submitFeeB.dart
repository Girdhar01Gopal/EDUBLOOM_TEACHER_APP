import 'package:get/get.dart';

import '../controller/submitFeeC.dart';

class SubmitFeeBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => SubmitFeeController());
  }
}