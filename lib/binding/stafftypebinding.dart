import 'package:get/get.dart';

import '../controller/stafftypecontroller.dart';


class Stafftypebinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Stafftypecontroller());
  }

}