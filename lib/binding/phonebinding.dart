import 'package:get/get.dart';

import '../controller/phonenumbercontroller.dart';

class Phonebinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Phonenumbercontroller());
  }

}