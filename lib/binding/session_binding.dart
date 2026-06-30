import 'package:get/get.dart';

import '../controller/session_controller.dart';

class SessionBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => SessionController());
  }
}