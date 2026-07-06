import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/login_model.dart';
import '../repo/repo.dart';
import '../res/app_url.dart';

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
            key: PrefConst.Userid,
            value: data.data!.userId.toString());
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

        // Fetch the per-user module access list before navigating so the
        // drawer/dashboard menu is filtered correctly on first render.
        await fetchModuleAccess(data.data!.userId, data.data!.schoolId);

        Get.offAllNamed(RouteName.dashboard_screen);
        isLoading.value = false;

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

  /// Fetches the logged-in user's per-module access rights and caches the
  /// raw list under [PrefConst.moduleAccess] so [RoleBasedModuleVisibility]
  /// can filter the drawer/dashboard menu against it.
  Future<void> fetchModuleAccess(int? userId, String? schoolId) async {
    if (userId == null || schoolId == null) return;
    try {
      final token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      final uri = Uri.parse(
        '${AppUrl.base_url}api/SchoolApp/GetUserAccessApp?userId=$userId&schoolId=$schoolId',
      );
      
      final response = await https.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawList = decoded is List
            ? decoded
            : (decoded is Map && decoded['data'] != null ? decoded['data'] as List : []);
                        print("module access list is ${rawList}");

        await PrefManager()
            .writeValue(key: PrefConst.moduleAccess, value: jsonEncode(rawList));
      } else {
        debugPrint("GetUserAccessApp error: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

}
