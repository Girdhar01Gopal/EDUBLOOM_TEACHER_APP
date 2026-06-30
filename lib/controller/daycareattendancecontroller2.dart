import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/AttendanceDatils12.dart';
import '../models/Attendetail11.dart';

class AttendanceDetailsDayCareController extends GetxController {
  final RxString schoolId = ''.obs;
  final RxString session = ''.obs;

  final RxList<DayCareStudent> studentList = <DayCareStudent>[].obs;
  final Rx<DayCareStudent?> selectedStudent = Rx<DayCareStudent?>(null);

  final List<Map<String, dynamic>> monthList = const [
    {'id': 1, 'name': 'January'},
    {'id': 2, 'name': 'February'},
    {'id': 3, 'name': 'March'},
    {'id': 4, 'name': 'April'},
    {'id': 5, 'name': 'May'},
    {'id': 6, 'name': 'June'},
    {'id': 7, 'name': 'July'},
    {'id': 8, 'name': 'August'},
    {'id': 9, 'name': 'September'},
    {'id': 10, 'name': 'October'},
    {'id': 11, 'name': 'November'},
    {'id': 12, 'name': 'December'},
  ];

  final Rx<Map<String, dynamic>?> selectedMonth = Rx<Map<String, dynamic>?>(null);

  final RxBool isStudentLoading = false.obs;
  final RxBool isAttendanceLoading = false.obs;

  final RxList<Attendetail11Data> allAttendanceList = <Attendetail11Data>[].obs;
  final RxList<AttendanceRowModel> attendanceList = <AttendanceRowModel>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? '';
    selectedMonth.value = monthList.first;

    await fetchDayCareStudents();
    await fetchAllDaycareAttendance();
  }

  Future<void> fetchDayCareStudents() async {
    try {
      isStudentLoading.value = true;

      final String url =
          'https://playschool.edubloom.in/api/DailyActiviesApp/GetAllDailyActivityAsynsApp'
          '?type=DayCare&schoolId=${schoolId.value}&session=${session.value}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);

        if (body is Map<String, dynamic> && body['data'] is List) {
          final List<dynamic> rawList = body['data'] as List<dynamic>;

          final List<DayCareStudent> parsed = rawList
              .map((e) => DayCareStudent.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();

          final Map<int, DayCareStudent> uniqueMap = {};
          for (final student in parsed) {
            uniqueMap[student.studentId] = student;
          }

          studentList.assignAll(uniqueMap.values.toList());

          if (studentList.isNotEmpty) {
            selectedStudent.value = studentList.first;
          }
        } else {
          studentList.clear();
          selectedStudent.value = null;
        }
      } else {
        studentList.clear();
        selectedStudent.value = null;
        Get.snackbar('Error', 'Unable to load students');
      }
    } catch (e) {
      studentList.clear();
      selectedStudent.value = null;
      Get.snackbar('Error', 'Failed to load students: $e');
    } finally {
      isStudentLoading.value = false;
    }
  }

  Future<void> fetchAllDaycareAttendance() async {
    try {
      isAttendanceLoading.value = true;

      final String url =
          'https://playschool.edubloom.in/api/AttendenceApp/GetAllDaycareAttendanceAsync/${schoolId.value}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        final model = Attendetail11.fromJson(body);

        allAttendanceList.assignAll(model.data ?? []);

        attendanceList.assignAll(
          (model.data ?? []).map((e) => AttendanceRowModel.fromGetApi(e)).toList(),
        );
      } else {
        allAttendanceList.clear();
        attendanceList.clear();
        Get.snackbar('Error', 'Unable to load attendance');
      }
    } catch (e) {
      allAttendanceList.clear();
      attendanceList.clear();
      Get.snackbar('Error', 'Failed to load attendance: $e');
    } finally {
      isAttendanceLoading.value = false;
    }
  }

  Future<void> searchAttendanceData() async {
    if (selectedStudent.value == null) {
      Get.snackbar('Error', 'Please select student name');
      return;
    }

    if (selectedMonth.value == null) {
      Get.snackbar('Error', 'Please select month');
      return;
    }

    try {
      isAttendanceLoading.value = true;

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/AttendenceApp/SearchActiveDaycareAttendanceAsync',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentId': selectedStudent.value!.studentId,
          'month': selectedMonth.value!['id'],
        }),
      );

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        final model = AttendanceDatils12.fromJson(body);

        attendanceList.assignAll(
          (model.listData ?? []).map((e) => AttendanceRowModel.fromPostApi(e)).toList(),
        );

        if (attendanceList.isEmpty) {
          Get.snackbar('Info', 'No attendance found for selected student and month');
        }
      } else {
        attendanceList.clear();
        Get.snackbar('Error', 'Search attendance failed');
      }
    } catch (e) {
      attendanceList.clear();
      Get.snackbar('Error', 'Failed to search attendance: $e');
    } finally {
      isAttendanceLoading.value = false;
    }
  }

  void setSelectedStudent(DayCareStudent? student) {
    selectedStudent.value = student;
  }

  void setSelectedMonth(String monthName) {
    selectedMonth.value = monthList.firstWhere(
          (element) => element['name'] == monthName,
      orElse: () => monthList.first,
    );
  }

  void onSearchTap() {
    searchAttendanceData();
  }

  String get totalHoursText {
    int totalSeconds = 0;

    for (final item in attendanceList) {
      final value = item.totalHour.trim();
      if (value.isEmpty || value == '-') continue;

      final parts = value.split(':');
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        totalSeconds += (h * 3600) + (m * 60) + s;
      }
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class DayCareStudent {
  final int studentId;
  final String studentName;

  DayCareStudent({
    required this.studentId,
    required this.studentName,
  });

  factory DayCareStudent.fromJson(Map<String, dynamic> json) {
    return DayCareStudent(
      studentId: int.tryParse('${json['studentId'] ?? 0}') ?? 0,
      studentName: '${json['studentName'] ?? 'Unnamed'}',
    );
  }
}

class AttendanceRowModel {
  final int sadid;
  final int studentId;
  final String studentName;
  final String status;
  final String fromTime;
  final String toTime;
  final String totalHour;
  final String date;
  final String actionText;

  AttendanceRowModel({
    required this.sadid,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.fromTime,
    required this.toTime,
    required this.totalHour,
    required this.date,
    required this.actionText,
  });

  factory AttendanceRowModel.fromGetApi(Attendetail11Data e) {
    return AttendanceRowModel(
      sadid: e.sadid ?? 0,
      studentId: e.studentId ?? 0,
      studentName: e.studentName ?? '-',
      status: e.status ?? '-',
      fromTime: (e.fromTime == null || e.fromTime!.trim().isEmpty) ? '-' : e.fromTime!,
      toTime: (e.toTime == null || e.toTime!.trim().isEmpty) ? '-' : e.toTime!,
      totalHour: (e.totalHour == null || e.totalHour!.trim().isEmpty) ? '-' : e.totalHour!,
      date: formatDate(e.adate),
      actionText: (e.action == '1') ? 'Active' : 'Inactive',
    );
  }

  factory AttendanceRowModel.fromPostApi(AttendanceDatils12Data e) {
    return AttendanceRowModel(
      sadid: e.sadid ?? 0,
      studentId: e.studentId ?? 0,
      studentName: e.studentName ?? '-',
      status: e.status ?? '-',
      fromTime: (e.fromTime == null || e.fromTime!.trim().isEmpty) ? '-' : e.fromTime!,
      toTime: (e.toTime == null || e.toTime!.trim().isEmpty) ? '-' : e.toTime!,
      totalHour: (e.totalHour == null || e.totalHour!.trim().isEmpty) ? '-' : e.totalHour!,
      date: formatDate(e.adate),
      actionText: (e.action == '1') ? 'Active' : 'Inactive',
    );
  }

  static String formatDate(String? input) {
    if (input == null || input.isEmpty) return '-';
    try {
      final dt = DateTime.parse(input);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      return '$day-$month-$year';
    } catch (_) {
      return input;
    }
  }
}