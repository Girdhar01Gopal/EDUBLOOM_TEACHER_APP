import 'package:get/get.dart';

import '../controller/notification_controller.dart';

class NotificationBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => NotificationController());
  }

}