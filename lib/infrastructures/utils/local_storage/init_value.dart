import 'package:get/get.dart';

import 'local_storage.dart';

class InitVariables {
  onInit() {
    PrefManager().initlizedStorage();
  }
}
