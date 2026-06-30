import 'package:get/get.dart';

import '../controller/fees_controller.dart';
import '../controller/feescontrollermaster.dart';

class Feesbindingmaster extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Feescontrollermaster());
  }

}