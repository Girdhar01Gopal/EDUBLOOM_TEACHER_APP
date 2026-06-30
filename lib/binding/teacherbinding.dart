import 'package:get/get.dart';

import '../controller/teachercontroller.dart';

class Teacherbinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => Teachercontroller());
  }
}