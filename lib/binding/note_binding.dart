import 'package:get/get.dart';

import '../controller/note_controller.dart';

class NoteBinding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut(() => NoteController());
  }
}