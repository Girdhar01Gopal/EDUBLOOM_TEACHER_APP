import 'package:get/get.dart';

import '../controller/registercontroller.dart';

class Registerbinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => RegisterController());
  }
}