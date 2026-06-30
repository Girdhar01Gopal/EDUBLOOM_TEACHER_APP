import 'package:get/get.dart';

import '../controller/addstudentdaycarecontroller.dart';


class StudentScreen2Bindings extends Bindings{

  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => StudentScreen2Controller());
  }

}