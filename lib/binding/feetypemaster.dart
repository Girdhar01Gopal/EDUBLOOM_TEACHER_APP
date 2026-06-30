import 'package:get/get.dart';

import '../controller/feetypemaster.dart';

class feetypebinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => FeeTypeController());
  }
}