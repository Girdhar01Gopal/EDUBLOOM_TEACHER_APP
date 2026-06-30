import 'package:get/get.dart';

import '../controller/staffattendancecontroller.dart';


class Staffattendancebinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Staffattendancecontroller());
  }

}