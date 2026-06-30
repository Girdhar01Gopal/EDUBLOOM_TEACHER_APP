import 'package:get/get.dart';

import '../infrastructures/routes/page_constants.dart';

class AppDrawerController extends GetxController {
  int selectedIndex = 0;
  Future<dynamic>? selectedWidget;

  void onSelectedWidget(int index) {
    selectedIndex = index;
    switch (index) {
      case 0:
        selectedWidget = Get.toNamed(RouteName.session_screen);
     /* case 1:
        selectedWidget = Get.toNamed(RouteName.homework_screen);
      case 2:
        selectedWidget = Get.toNamed(RouteName.timetable_screen);
      case 3:
        selectedWidget = Get.toNamed(RouteName.syllabus_screen);
      case 4:
        selectedWidget = Get.toNamed(RouteName.notes_screen);
      case 5:
        selectedWidget = Get.toNamed(RouteName.attendence_main_screen);
      case 7:
        selectedWidget = Get.toNamed(RouteName.enquiry_screen);
      case 8:
        selectedWidget = Get.toNamed(RouteName.fees_screen);
      case 9:
        selectedWidget = Get.toNamed(RouteName.gallery_screen);
      case 10:
        selectedWidget = Get.toNamed(RouteName.teacher_screen);
      case 11:
        selectedWidget = Get.toNamed(RouteName.calender_screen);
      case 12:
        selectedWidget = Get.toNamed(RouteName.profile_screen);*/
    }
  }
}
