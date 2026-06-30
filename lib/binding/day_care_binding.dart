import 'package:get/get.dart';

import '../controller/day_care_controller.dart';

class DayCareBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => DayCareController());
  }

}