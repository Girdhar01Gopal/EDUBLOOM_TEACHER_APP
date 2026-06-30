import 'package:get/get.dart';

import '../controller/class_controller.dart';

class ClassBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => ClassController());
    // TODO: implement dependencies
  }

}