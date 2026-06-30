import 'package:get/get.dart';

import '../controller/addteachercontroller.dart';


class Addteacherbinding extends Bindings{

  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Addteachercontroller());
  }

}