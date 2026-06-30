import 'package:get/get.dart';

import '../controller/add_products_controller.dart';

class AddProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductsController>(() => AddProductsController());
  }
}