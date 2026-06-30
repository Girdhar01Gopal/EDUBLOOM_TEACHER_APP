import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/fee_type_model.dart';
import '../models/fees_duration_model.dart';
import 'package:http/http.dart'as http;
import '../models/student_fee_model.dart';
import '../res/app_url.dart';
class AddDiscountController extends GetxController{

  TextEditingController remarkController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  var feesDurationList = <DListData>[].obs;
  var isLoading = true.obs;
  var filteredList = <ListData>[].obs;
  var token ="";
  var feeTypeList = <fData>[].obs;
  var selectedFeesDuration = 0.obs;
  var selectedFeesDurationName = "".obs;
  var selectedFeeType = 0.obs;
  var selectedFeeTypeName = "".obs;
    RxList<Map<String, dynamic>> discountDetails = <Map<String, dynamic>>[].obs;

  var schoolid;
  var studentId = 0;

  @override
  void onInit() async {
    final args = Get.arguments;
    if (args is Map) {
      final rows = args['selectedRows'];
      filteredList.value = rows is List ? List<ListData>.from(rows) : [];
      studentId = (args['studentId'] as int?) ?? 0;
    } else if (args is List<ListData>) {
      filteredList.value = args;
      studentId = filteredList.isNotEmpty ? filteredList.first.studentId : 0;
    }
    schoolid = await PrefManager().readValue(key: PrefConst.schollId);
    await fetchFeesDuration();
    await fetchFeeType();
    super.onInit();
  }

  
  // Add this method to get the total amount for selected fee type and duration
  int getTotalAmount() {
    try {
      // Find the matching fee from filteredList based on selected fee type and duration
      final matchingFee = filteredList.firstWhere(
        (fee) => fee.feeType == selectedFeeTypeName.value && 
                 fee.feesDuration == selectedFeesDurationName.value,
        orElse: () => filteredList.first,
      );
      
      return int.tryParse(matchingFee.amount ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<void> fetchFeesDuration() async {

    try {
      isLoading(true);
      var response = await http.get(Uri.parse('${AppUrl.base_url}api/FeeMasterApp/ViewFeesDurationApp/$schoolid'),
          headers : {
           //// 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }
      );
      if (response.statusCode == 200) {
        print(response);
        print(response.body);
        var jsonData = json.decode(response.body);
        FeesDurationModel feesDurationModel = FeesDurationModel.fromJson(jsonData);
        feesDurationList.assignAll(feesDurationModel.listData ?? []);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFeeType() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse('${AppUrl.base_url}api/FeeMasterApp/ViewFeeTypeApp/$schoolid'),
      
          headers : {
            //'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });
          print('${AppUrl.base_url}api/Fee/ViewFeeType/$schoolid');
      if (response.statusCode == 200) {
        print(response);
        print(response.body);
        var jsonData = json.decode(response.body);
        FeeTypeModel feeTypeModel = FeeTypeModel.fromJson(jsonData);
        feeTypeList.assignAll(feeTypeModel.listData ?? []);
      }
    } finally {
      isLoading(false);
    }
  }
  
Future<void> submitDiscount(
   
    var feesDurationId,
    var feeDuration,
    var feeType,
    var feeType1,
    var discount,
    var remark,
    var registrationno,
    var calssid,
    var sectionid,
    var session,  // Added session
    var schoolId, // Added schoolId
  ) async {
    isLoading(true);
    final url = '${AppUrl.base_url}api/DiscountApp/InsertDiscountApp';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": 0,
          "feeDurationId": feesDurationId,
          "feeDuration": feeDuration.toString(),
          "feeType": feeType,
          "feeType1": feeType1.toString(),
          "discount": int.tryParse(discount.toString()) ?? 0,
          "remark": remark.toString(),
          "file": "string",
          "action": "1",
          "studentId": registrationno,
          "classId": calssid,
          "sectionId": sectionid,
          "session": session.toString(),
          "schoolId": schoolId.toString(),
        }),
      );
print(response.statusCode);
print(response.body);
      if (response.statusCode == 200) {
        print(url);
        print(response.body);
       Get.offAllNamed(RouteName.dashboard_screen);
        var data = json.decode(response.body);
        if (response.statusCode == 409) {
          Get.snackbar('Success', 'Discount already added once');
        }
        Discount();
      } else {
        Get.snackbar('Error', 'Failed to add discount');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading(false);
    }
  }
void Discount() async {
  PrefManager().writeValue(key: PrefConst.feeType, value: selectedFeeTypeName.value);
  PrefManager().writeValue(key: PrefConst.feeDuration, value: selectedFeesDurationName.value);

  final url = Uri.parse(
    "${AppUrl.base_url}api/FeePaymentApp/GetDiscountdetailsApp/${filteredList.first.session}/${filteredList.first.schoolId}?registrationNo=${filteredList.first.registrationNo}",
  );
  
  var discount = 0;  // Default discount value

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token', // Uncomment if needed
      },
    );

    if (response.statusCode == 200) {
      print(url);
      print(response.body);
      final data = jsonDecode(response.body);

      // Assuming the response contains a 'discount' field. Safely parse it.
      if (data['discount'] != null) {
        // Ensure discount is a valid number (int or double)
        discountDetails.assignAll(response.body.isNotEmpty
          ? (data as List).map((e) => Map<String, dynamic>.from(e)).toList()
          : []);
          print(discountDetails);
          discount = discountDetails.isNotEmpty
          ? (discountDetails.first['discount']
              ? discountDetails.first['discount'] 
              : int.tryParse(discountDetails.first['discount'].toString()) ?? 0)
          : 0;
          print(discount);
          Get.offAllNamed(RouteName.dashboard_screen);
      } else {
        discount = 0; // Default to 0 if discount field is missing
      }

      // Send the discount back to the parent page
      Get.back(result: discount);
    } else {
      print('Failed to load discount');
    }
  } catch (error) {
    print('Error: $error');
  }
}
}