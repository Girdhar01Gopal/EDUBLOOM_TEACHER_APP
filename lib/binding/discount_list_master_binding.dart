
import 'package:get/get.dart';

import '../controller/discount_list_master.dart';

class discountlistmasterbinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => DiscountListMasterController());
  }

}