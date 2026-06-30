import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/response/status.dart';

class

LogInPageController extends GetxController {
  final scrollController = ScrollController();
  RxDouble offset = 0.0.obs;
  var isBaseUrl = false.obs;
  var isGetBaseUrl = false.obs;
  final isLoading = false.obs;
  final rxRequestStatus = Status.Loading.obs;

  void setError(String _value) => error.value = _value;
  void setRxRequestStatus(Status _value) => rxRequestStatus.value = _value;

  RxString error = "".obs;
  RxBool isSelected = false.obs;
  RxBool isChecked = false.obs;
  RxString login = ''.obs;
  RxString password = ''.obs;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  RxBool loading = false.obs;
  TextEditingController userNamecontroller = TextEditingController(text: "" );
  TextEditingController userPasswordcontroller = TextEditingController(text: "");

  var baseUrl = "".obs;
  var secUrl = "".obs;
  var schoolemail = "".obs;
  var schoolphone = "".obs;
  var schoolImage = "".obs;
  var schoolname = "".obs;
  final RxBool isObscure = true.obs;
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(onScroll);

    isLoading.value = true;
  }
  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  void onScroll() {
    offset.value = (scrollController.hasClients) ? scrollController.offset : 0;
  }

  void radio() {
    isSelected.value = !isSelected.value;
  }
}
