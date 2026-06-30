import 'package:get/get.dart';

import '../controller/communicationcontroller.dart';

class Communicationbinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => Communicationcontroller());
    // TODO: implement dependencies
  }

}