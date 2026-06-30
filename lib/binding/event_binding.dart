import 'package:get/get.dart';

import '../controller/event_controller.dart';

class EventBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => EventController());
  }

}