import 'package:get/get.dart';
import '../controller/DailyCollectionHeadWiseController.dart';

class DailyCollectionFeeHeadWiseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyCollectionFeeHeadWiseController>(
          () => DailyCollectionFeeHeadWiseController(),
    );
  }
}