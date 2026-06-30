import 'package:get/get.dart';
import '../controller/parent_id_controller.dart';

class ParentIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentIdController>(() => ParentIdController());
  }
}