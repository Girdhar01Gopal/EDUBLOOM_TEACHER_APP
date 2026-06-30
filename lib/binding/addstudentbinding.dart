import 'package:get/get.dart';

import '../controller/addstudentcontrollermaster.dart';


class Addstudentbinding extends Bindings{

  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => Addstudentcontrollermaster());
  }

}