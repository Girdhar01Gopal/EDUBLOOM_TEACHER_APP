import 'package:get/get.dart';

import '../controller/staffcontroller.dart';

class Staffviewbinding extends Bindings{

  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Staffcontroller());
  }

}