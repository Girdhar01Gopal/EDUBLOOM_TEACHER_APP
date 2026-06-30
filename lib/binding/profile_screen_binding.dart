import 'package:get/get.dart';

import '../controller/profile_page_controller.dart';

class ProfileScreenBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => ProfilePageController(),);
  }

}