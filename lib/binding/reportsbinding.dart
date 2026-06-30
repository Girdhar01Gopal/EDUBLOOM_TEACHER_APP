import 'package:get/get.dart';

import '../controller/reportscontroller.dart';

class Reportsbinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => Reportscontroller());
  }
}