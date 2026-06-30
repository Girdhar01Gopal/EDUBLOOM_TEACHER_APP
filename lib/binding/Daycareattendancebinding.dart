import 'package:get/get.dart';

import '../controller/Daycareattendencecontroller.dart';

class Daycareattendancebinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Daycareattendencecontroller());
  }

}