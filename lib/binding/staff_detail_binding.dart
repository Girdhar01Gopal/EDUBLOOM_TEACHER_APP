import 'package:get/get.dart';
import '../controller/staff_detail_conroller.dart';

class StaffDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffDetailController>(
          () => StaffDetailController(),
    );
  }
}