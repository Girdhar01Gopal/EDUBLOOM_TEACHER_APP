import 'package:get/get.dart';

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────

class StudentModel {
  final String id;
  final String name;
  final String className;
  final String type; // 'daycare' or 'preschool'
  final String avatarInitials;

  StudentModel({
    required this.id,
    required this.name,
    required this.className,
    required this.type,
    required this.avatarInitials,
  });
}

class ActivityEntry {
  final String studentId;
  final String studentName;
  final String className;
  final String remark;
  final int stars; // 1-5
  final String mood; // 'good' / 'bad'
  final int iqLevel; // 1-5
  final int learningSkill; // 1-5
  final DateTime date;

  ActivityEntry({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.remark,
    required this.stars,
    required this.mood,
    required this.iqLevel,
    required this.learningSkill,
    required this.date,
  });
}

// ─────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────

class DailyActivityController extends GetxController {
  // ── Tab ──────────────────────────────────────
  final RxInt currentTab = 0.obs;

  // ── Dropdowns ────────────────────────────────
  final RxString selectedSchoolType = 'preschool'.obs; // 'daycare' | 'preschool'
  final RxString selectedClass = ''.obs;

  // ── Students ─────────────────────────────────
  final RxList<StudentModel> displayedStudents = <StudentModel>[].obs;
  final Rx<StudentModel?> selectedStudent = Rx<StudentModel?>(null);

  // ── Form fields ──────────────────────────────
  final RxString remark = ''.obs;
  final RxInt stars = 0.obs;
  final RxString mood = ''.obs;       // 'good' | 'bad' | ''
  final RxInt iqLevel = 0.obs;         // 1-5
  final RxInt learningSkill = 0.obs;   // 1-5

  // ── Saved entries ────────────────────────────
  final RxList<ActivityEntry> entries = <ActivityEntry>[].obs;

  // ── Loading simulation ───────────────────────
  final RxBool isLoading = false.obs;

  // ─────────────────────────────────────────────
  // DUMMY DATA
  // ─────────────────────────────────────────────

  final List<StudentModel> _daycareStudents = [
    StudentModel(id: 'd1', name: 'Aarav Sharma',    className: 'Nursery A', type: 'daycare', avatarInitials: 'AS'),
    StudentModel(id: 'd2', name: 'Priya Mehta',     className: 'Nursery A', type: 'daycare', avatarInitials: 'PM'),
    StudentModel(id: 'd3', name: 'Rohan Gupta',     className: 'Nursery B', type: 'daycare', avatarInitials: 'RG'),
    StudentModel(id: 'd4', name: 'Sneha Patel',     className: 'Nursery B', type: 'daycare', avatarInitials: 'SP'),
    StudentModel(id: 'd5', name: 'Kabir Singh',     className: 'Toddler',   type: 'daycare', avatarInitials: 'KS'),
    StudentModel(id: 'd6', name: 'Ananya Joshi',    className: 'Toddler',   type: 'daycare', avatarInitials: 'AJ'),
  ];

  final List<StudentModel> _preschoolStudents = [
    StudentModel(id: 'p1', name: 'Vivaan Kapoor',   className: 'LKG',  type: 'preschool', avatarInitials: 'VK'),
    StudentModel(id: 'p2', name: 'Diya Verma',      className: 'LKG',  type: 'preschool', avatarInitials: 'DV'),
    StudentModel(id: 'p3', name: 'Arjun Nair',      className: 'UKG',  type: 'preschool', avatarInitials: 'AN'),
    StudentModel(id: 'p4', name: 'Mira Iyer',       className: 'UKG',  type: 'preschool', avatarInitials: 'MI'),
    StudentModel(id: 'p5', name: 'Ishaan Reddy',    className: 'Jr KG',type: 'preschool', avatarInitials: 'IR'),
    StudentModel(id: 'p6', name: 'Kavya Desai',     className: 'Jr KG',type: 'preschool', avatarInitials: 'KD'),
    StudentModel(id: 'p7', name: 'Reyansh Tiwari',  className: 'Sr KG',type: 'preschool', avatarInitials: 'RT'),
    StudentModel(id: 'p8', name: 'Pooja Yadav',     className: 'Sr KG',type: 'preschool', avatarInitials: 'PY'),
  ];

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────

  List<String> get classOptions {
    final source = selectedSchoolType.value == 'daycare'
        ? _daycareStudents
        : _preschoolStudents;
    return source.map((s) => s.className).toSet().toList();
  }

  bool get canSubmit =>
      selectedStudent.value != null &&
          remark.value.trim().isNotEmpty &&
          stars.value > 0 &&
          mood.value.isNotEmpty &&
          iqLevel.value > 0 &&
          learningSkill.value > 0;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadStudentsByType('preschool');
  }

  // ─────────────────────────────────────────────
  // METHODS
  // ─────────────────────────────────────────────

  /// Called when school type dropdown changes
  void onSchoolTypeChanged(String type) async {
    selectedSchoolType.value = type;
    selectedClass.value = '';
    selectedStudent.value = null;
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600)); // simulate API
    _loadStudentsByType(type);
    isLoading.value = false;
  }

  void _loadStudentsByType(String type) {
    final all = type == 'daycare' ? _daycareStudents : _preschoolStudents;
    displayedStudents.assignAll(all);
  }

  /// Called when class dropdown changes
  void onClassChanged(String className) {
    selectedClass.value = className;
    selectedStudent.value = null;
    final source = selectedSchoolType.value == 'daycare'
        ? _daycareStudents
        : _preschoolStudents;
    final filtered = source.where((s) => s.className == className).toList();
    displayedStudents.assignAll(filtered);
  }

  void onStudentSelected(StudentModel student) {
    selectedStudent.value = student;
  }

  void onRemarkChanged(String value) => remark.value = value;

  void onStarTapped(int value) =>
      stars.value = (stars.value == value) ? 0 : value;

  void onMoodSelected(String value) =>
      mood.value = (mood.value == value) ? '' : value;

  void onIqLevelChanged(int value) =>
      iqLevel.value = (iqLevel.value == value) ? 0 : value;

  void onLearningSkillChanged(int value) =>
      learningSkill.value = (learningSkill.value == value) ? 0 : value;

  void submitActivity() {
    if (!canSubmit) return;

    final entry = ActivityEntry(
      studentId: selectedStudent.value!.id,
      studentName: selectedStudent.value!.name,
      className: selectedStudent.value!.className,
      remark: remark.value.trim(),
      stars: stars.value,
      mood: mood.value,
      iqLevel: iqLevel.value,
      learningSkill: learningSkill.value,
      date: DateTime.now(),
    );
    entries.add(entry);
    _resetForm();
    currentTab.value = 1; // jump to view tab
    Get.snackbar(
      '✅ Activity Saved',
      '${entry.studentName} ki activity successfully add ho gayi!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _resetForm() {
    selectedStudent.value = null;
    remark.value = '';
    stars.value = 0;
    mood.value = '';
    iqLevel.value = 0;
    learningSkill.value = 0;
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
  }

  // ─────────────────────────────────────────────
  // VIEW TAB HELPERS
  // ─────────────────────────────────────────────

  int get totalStudentsRated => entries.length;

  double get averageStars {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.stars).reduce((a, b) => a + b) /
        entries.length;
  }

  int goodCount() => entries.where((e) => e.mood == 'good').length;
  int badCount()  => entries.where((e) => e.mood == 'bad').length;
}