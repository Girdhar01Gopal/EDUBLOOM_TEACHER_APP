import 'package:get/get.dart';

import '../controller/student_controller.dart';

class StudentBinding extends Bindings{

  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => StudentController());
  }

}