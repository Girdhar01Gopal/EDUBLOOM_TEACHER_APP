import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/login_model.dart';
import '../repo/repo.dart';

class LoginViewModel with ChangeNotifier {
  final myRepo = LoginRepository();
  final enquiryRepo = EnquiryRepository();
  final isLoading = false.obs;

  Future<void> loginApi(dynamic data) async {
    isLoading.value = true;
    myRepo.loginApi(data: data).then((value) async {
      var data = Login_Model.fromJson(value);

      if (data.data == null) {
        ShortMessage.toast(
          title: data.messages.toString(),
        );
        isLoading.value = false;
      }
        else if(data.data!.webandApp=="Web"){
           ShortMessage.toast(
          title: "Please login through web ! You are not authorized to login through app",
        );
        }
       else if (data.data != null) {
        ShortMessage.toast(
          title: data.messages.toString(),
        );
      
        Get.offAllNamed(RouteName.dashboard_screen);
        isLoading.value = false;

        debugPrint("please proceed ! path is clear");
        PrefManager().writeValue(key: PrefConst.isLoggedIn, value: "Yes");
        PrefManager().writeValue(
            key: PrefConst.token,
            value: data.data!.accessToker!.token.toString());
        PrefManager().writeValue(
            key: PrefConst.expireDate,
            value: data.data!.accessToker!.expireIn.toString());
            PrefManager().writeValue(
            key: PrefConst.schoolname,
            value: data.data!.schoolName.toString());
            PrefManager().writeValue(
            key: PrefConst.schoollogo,
            value: data.data!.logoWithName.toString());
        PrefManager().writeValue(
            key: PrefConst.Name,
            value: data.data!.name.toString());
            PrefManager().writeValue(
            key: PrefConst.RName,
            value: data.data?.role?.roleName .toString());
            PrefManager().writeValue(
            key: PrefConst.session,
            value: data.data!.currentSession.toString());
       var user =  PrefManager().writeValue(
            key: PrefConst.schollId, value: data.data!.schoolId.toString());
        print(data.data!.accessToker!.expireIn.toString());
        print("school id  is ${user}");
        // PrefManager().writeValue(key: PrefConst.userPassword, value:  userPassword value.text.toString());

        if (kDebugMode) {
          print(" no error this side");
        }
        isLoading.value = false;
      } else if (data.statusCode == 400) {
        debugPrint("chakkar hai yahi pr re ");
        ShortMessage.toast(
          title: data.messages.toString(),
        );
      }
    }).onError((error, stackTrace) {
      ShortMessage.toast(title: "Something went wrong!\n Please Try again ");
      isLoading.value = false;
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }
}
