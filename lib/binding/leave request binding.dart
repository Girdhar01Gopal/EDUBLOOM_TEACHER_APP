import 'package:get/get.dart';

import '../controller/leave request controller.dart';


class LeaveRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveRequestController>(() => LeaveRequestController());
  }
}