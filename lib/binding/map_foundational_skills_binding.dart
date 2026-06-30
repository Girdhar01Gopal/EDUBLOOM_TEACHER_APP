import 'package:get/get.dart';
import '../controller/map_foundational_skills_controller.dart';

class MapFoundationalSkillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapFoundationalSkillsController>(
          () => MapFoundationalSkillsController(),
    );
  }
}