import 'package:get/get.dart';

import '../controller/product_quantity_controller.dart';

class ProductQuantityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductQuantityController>(
          () => ProductQuantityController(),
    );
  }
}