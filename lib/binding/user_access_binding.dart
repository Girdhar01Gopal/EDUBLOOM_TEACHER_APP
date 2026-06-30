import 'package:get/get.dart';
import '../controller/user_access_controller.dart';

class UserAccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserAccessController>(() => UserAccessController());
  }
}