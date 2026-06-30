import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/session_model.dart' as session_model;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../res/app_url.dart';

// ✅ PDF + Share deps
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ParentIdRow {
  final String registrationNo;
  final String studentName;
  final String fatherName;
  final String className;
  final String sectionName;
  final String phone;
  final String parentId;
  final String password;

  ParentIdRow({
    required this.registrationNo,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.sectionName,
    required this.phone,
    required this.parentId,
    required this.password,
  });

  factory ParentIdRow.fromJson(Map<String, dynamic> json) {
    return ParentIdRow(
      registrationNo: (json['registrationNo'] ?? '-').toString(),
      studentName: (json['studentName'] ?? '-').toString(),
      fatherName: (json['fatherName'] ?? '-').toString(),
      className: (json['className'] ?? '-').toString(),
      sectionName: (json['sectionName'] ?? '-').toString(),
      phone: (json['phone'] ?? '-').toString(),
      parentId: (json['parentId'] ?? '-').toString(),
      password: (json['ppassword'] ?? '-').toString(),
    );
  }
}

class ParentIdController extends GetxController {
  var isLoading = true.obs;

  // ✅ Tab index to auto-switch tab
  var tabIndex = 0.obs;

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null);
  var session = ''.obs;

  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rx<ListDatta?>(null);

  var rows = <ParentIdRow>[].obs;

  String schoolId = "";
  String token = "";

  final String postApi =
      "https://playschool.edubloom.in/api/StudentApp/GetViewStudentParentIdApp";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    token = await PrefManager().readValue(key: PrefConst.token);
    await _loadMasters();
  }

  Future<void> _loadMasters() async {
    try {
      isLoading(true);
      await Future.wait([
        fetchSessions(),
        fetchClasses(),
        fetchSections(),
      ]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(cs);
          selectedSession.value = cs;
          session.value = cs.session ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchClasses() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ?? [];
        selectedClass.value = null;
      }
    } catch (_) {}
  }

  Future<void> fetchSections() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data =
            decoded['listData'] ?? decoded['data'] ?? [];
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      }
    } catch (_) {}
  }

  void setSelectedClass(ListDataa? val) => selectedClass.value = val;
  void setSelectedSection(ListDatta? val) => selectedSection.value = val;

  bool _validate() {
    if (selectedSession.value == null ||
        (selectedSession.value?.session ?? "").isEmpty) {
      Get.snackbar("Required", "Please Select Session");
      return false;
    }
    if (selectedClass.value == null) {
      Get.snackbar("Required", "Please Select Class");
      return false;
    }
    if (selectedSection.value == null) {
      Get.snackbar("Required", "Please Select Section");
      return false;
    }
    return true;
  }

  Future<void> searchParentIdList() async {
    if (!_validate()) return;

    try {
      isLoading(true);
      rows.clear();

      final body = {
        "classId": selectedClass.value?.classId ?? 0,
        "sectionId": selectedSection.value?.sectionId ?? 0,
        "session": selectedSession.value?.session ?? "",
        "schoolId": schoolId,
      };

      final response = await http.post(
        Uri.parse(postApi),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list = decoded['listData'] ?? [];

        rows.value = list.map((e) => ParentIdRow.fromJson(e)).toList();

        if (rows.isEmpty) {
          Get.snackbar("Result", "No Data Found");
        } else {
          Get.snackbar("Success", "Loaded ${rows.length} records");
          tabIndex.value = 1; // ✅ Auto switch to View tab
        }
      } else {
        Get.snackbar("Error", "API failed (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Uint8List> _buildParentIdPdfBytes() async {
    final pdf = pw.Document();

    final headers = [
      "S.No",
      "Registration No",
      "Student Name",
      "Father Name",
      "Class",
      "Section",
      "Mobile",
      "Parent Id",
      "Password",
    ];

    final data = List<List<String>>.generate(rows.length, (i) {
      final r = rows[i];
      return [
        "${i + 1}",
        r.registrationNo,
        r.studentName,
        r.fatherName,
        r.className,
        r.sectionName,
        r.phone,
        r.parentId,
        r.password,
      ];
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [
          pw.Text(
            "Parent Id List",
            style:
            pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Session: ${selectedSession.value?.session ?? "-"} | Class: ${selectedClass.value?.className ?? "-"} | Section: ${selectedSection.value?.section ?? "-"}",
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle:
            pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(0.6),
              1: const pw.FlexColumnWidth(1.4),
              2: const pw.FlexColumnWidth(1.6),
              3: const pw.FlexColumnWidth(1.6),
              4: const pw.FlexColumnWidth(1.0),
              5: const pw.FlexColumnWidth(1.0),
              6: const pw.FlexColumnWidth(1.2),
              7: const pw.FlexColumnWidth(1.2),
              8: const pw.FlexColumnWidth(1.0),
            },
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> downloadParentIdPdf() async {
    try {
      if (rows.isEmpty) {
        Get.snackbar("Required", "No Data Found");
        return;
      }

      isLoading(true);

      final bytes = await _buildParentIdPdfBytes();
      final dir = await getApplicationDocumentsDirectory();

      final fileName =
          "ParentIdList_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(bytes, flush: true);
      Get.snackbar("Downloaded", "PDF saved: ${file.path}");
    } catch (e) {
      Get.snackbar("Error", "PDF download failed: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> shareParentIdPdf() async {
    try {
      if (rows.isEmpty) {
        Get.snackbar("Required", "No Data Found");
        return;
      }

      isLoading(true);

      final bytes = await _buildParentIdPdfBytes();
      final dir = await getTemporaryDirectory();

      final fileName =
          "ParentIdList_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Parent Id List PDF",
      );
    } catch (e) {
      Get.snackbar("Error", "PDF share failed: $e");
    } finally {
      isLoading(false);
    }
  }
}