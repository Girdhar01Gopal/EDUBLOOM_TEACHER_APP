import 'package:get/get.dart';
import '../controller/day_care_fee_master.dart';

class DayCareFeeMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayCareFeeMasterController>(() => DayCareFeeMasterController());
  }
}
