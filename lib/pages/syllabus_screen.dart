import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/syllabus_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';

const Color sylMaroon = Color(0xFFA1265C);
const Color sylMaroonShade50 = Color(0xFFF7EEF2);
const Color sylMaroonShade300 = Color(0xFFD195AF);
const Color sylMaroonShade400 = Color(0xFFC17294);
const Color sylMaroonShade600 = Color(0xFFB24E7A);
const Color sylMaroonShade700 = Color(0xFFA83768);
const Color sylMaroonShade800 = Color(0xFF99144E);

class SyllabusScreen extends GetView<SyllabusController> {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: sylMaroonShade800,
          title: const Text(
            "📚 Syllabus",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.add, color: Colors.white),
                  text: "Add Syllabus"),
              Tab(
                  icon: Icon(Icons.view_list, color: Colors.white),
                  text: "View Syllabus"),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            AddSyllabusTab(),
            ViewSyllabusTab(),
          ],
        ),
      ),
    );
  }
}

// ========================== ADD SYLLABUS TAB ==========================
class AddSyllabusTab extends GetView<SyllabusController> {
  const AddSyllabusTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // 🆕 dropdown -> horizontal multi-select chips
          _sectionLabel("Select Class (Multiple)"),
          SizedBox(height: 8.h),
          _classMultiSelect(),
          SizedBox(height: 16.h),

          _sectionLabel("Select Section (Multiple)"),
          SizedBox(height: 8.h),
          _sectionMultiSelect(),
          SizedBox(height: 16.h),

          _sectionLabel("Select Subject (Multiple)"),
          SizedBox(height: 8.h),
          _subjectMultiSelect(),
          SizedBox(height: 16.h),

          Obx(
                () => GestureDetector(
              onTap: () => controller.pickDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Syllabus Date',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  initialValue: controller.getDisplayDate(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          _inputField('Description', controller.description),
          SizedBox(height: 16.h),

          _buildFilePicker(context),
          SizedBox(height: 24.h),

          Obx(
                () => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.pink.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ElevatedButton.icon(
                icon: controller.isLoading.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  controller.isLoading.value ? "Submitting..." : "Submit",
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.registerSyllabus(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                  EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w700,
      color: Colors.blueGrey.shade800,
    ),
  );

  // 🆕 horizontal scrollable multi-select chips for Class
  Widget _classMultiSelect() {
    return SizedBox(
      height: 42.h,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.listDataa.isEmpty) {
          return Text(
            "No classes found",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          );
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.listDataa.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final cls = controller.listDataa[index];
            return Obx(() {
              final isSelected =
              controller.selectedClassIds.contains(cls.classId);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (cls.classId != null) {
                    controller.toggleClassSelection(cls.classId!);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? sylMaroon : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? sylMaroon : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle,
                            size: 14.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        cls.className ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  // 🆕 horizontal scrollable multi-select chips for Section
  Widget _sectionMultiSelect() {
    return SizedBox(
      height: 42.h,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.sectionList.isEmpty) {
          return Text(
            "No sections found",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          );
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.sectionList.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final sec = controller.sectionList[index];
            return Obx(() {
              final isSelected =
              controller.selectedSectionIds.contains(sec.sectionId);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (sec.sectionId != null) {
                    controller.toggleSectionSelection(sec.sectionId!);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? sylMaroon : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? sylMaroon : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle,
                            size: 14.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        sec.section ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  // 🆕 horizontal scrollable multi-select chips for Subject
  Widget _subjectMultiSelect() {
    return SizedBox(
      height: 42.h,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.subjectlist.isEmpty) {
          return Text(
            "No subjects found",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          );
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.subjectlist.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final subj = controller.subjectlist[index];
            return Obx(() {
              final isSelected =
              controller.selectedSubjectIds.contains(subj.subjectId);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (subj.subjectId != null) {
                    controller.toggleSubjectSelection(subj.subjectId!);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? sylMaroon : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? sylMaroon : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle,
                            size: 14.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        subj.subject ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _inputField(String label, RxString controllerValue) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ).copyWith(labelText: label),
      onChanged: (val) => controllerValue.value = val,
    );
  }

  Widget _buildFilePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Syllabus File (Image / PDF)",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Obx(() {
          final file = controller.pdfFile.value;
          return GestureDetector(
            onTap: () => _showPickerOptions(context),
            child: Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: sylMaroonShade300, width: 1.5),
                borderRadius: BorderRadius.circular(12.r),
                color: sylMaroonShade50,
              ),
              child: file != null
                  ? _buildFilePreview(file)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 40.sp, color: sylMaroonShade400),
                  SizedBox(height: 8.h),
                  Text("Tap to select file",
                      style: TextStyle(
                          fontSize: 14.sp, color: sylMaroonShade600)),
                  SizedBox(height: 4.h),
                  Text("Camera • Gallery • PDF",
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
        }),
        Obx(() => controller.pdfFile.value != null
            ? Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              controller.pdfFile.value = null;
              controller.file.value = '';
            },
            icon: const Icon(Icons.delete_outline,
                color: Colors.red, size: 18),
            label: const Text("Remove",
                style: TextStyle(color: Colors.red)),
          ),
        )
            : const SizedBox()),
      ],
    );
  }

  Widget _buildFilePreview(File file) {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    if (isPdf) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf,
              size: 54.sp, color: Colors.red.shade400),
          SizedBox(height: 8.h),
          Text(
            file.path.split('/').last,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text("PDF Selected ✓",
              style: TextStyle(
                  fontSize: 12.sp, color: Colors.green.shade600)),
        ],
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(file, fit: BoxFit.cover),
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Image Selected ✓",
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 16.h),
              Text("Select File From",
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pickerOptionTile(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    color: Colors.blue,
                    onTap: () async {
                      Get.back();
                      final picker = ImagePicker();
                      final photo = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 85);
                      if (photo != null) {
                        controller.pdfFile.value = File(photo.path);
                        controller.file.value = photo.path;
                      }
                    },
                  ),
                  _pickerOptionTile(
                    icon: Icons.photo_library,
                    label: "Gallery",
                    color: Colors.purple,
                    onTap: () async {
                      Get.back();
                      final picker = ImagePicker();
                      final photo = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 85);
                      if (photo != null) {
                        controller.pdfFile.value = File(photo.path);
                        controller.file.value = photo.path;
                      }
                    },
                  ),
                  _pickerOptionTile(
                    icon: Icons.picture_as_pdf,
                    label: "PDF",
                    color: Colors.red,
                    onTap: () async {
                      Get.back();
                      FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null &&
                          result.files.single.path != null) {
                        controller.pdfFile.value =
                            File(result.files.single.path!);
                        controller.file.value = result.files.single.name;
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(label,
              style:
              TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ========================== VIEW SYLLABUS TAB ==========================
class ViewSyllabusTab extends StatefulWidget {
  const ViewSyllabusTab({super.key});

  @override
  State<ViewSyllabusTab> createState() => _ViewSyllabusTabState();
}

class _ViewSyllabusTabState extends State<ViewSyllabusTab> {
  final SyllabusController controller = Get.find<SyllabusController>();

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  // 🆕 search bar state (Homework jaisa hi)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 🆕 FIX: postFrameCallback se call karo, warna navigation ke beech
    // "setState()/markNeedsBuild() called during build" crash aata hai
    // aur us crash ki wajah se naya data screen pe render nahi hota.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSyllabus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ flutter_file_downloader se download — same logic
  Future<void> _downloadAndShare({
    required String url,
    required String fileName,
    required int index,
    required String subjectName,
    required String className,
    required String sectionName,
    required String remarks,
    required String date,
  }) async {
    setState(() {
      _isDownloading[index] = true;
      _downloadProgress[index] = 0;
    });

    FileDownloader.downloadFile(
      url: url,
      name: fileName,
      notificationType: NotificationType.all,
      onProgress: (name, progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[index] = progress / 100;
          });
        }
        if (kDebugMode) {
          print("Downloading: $name $progress");
        }
      },
      onDownloadCompleted: (path) async {
        if (mounted) {
          setState(() {
            _isDownloading[index] = false;
            _downloadProgress[index] = 1.0;
          });
        }

        _showSnack("Downloaded ✓",
            "Saved to Downloads folder", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));

        await Share.share(
          '📚 Subject: $subjectName\n🏫 Class: $className\n📋 Section: $sectionName\n📝 Remarks: $remarks\n🗓️ Date: $date',
          subject: 'Syllabus – $subjectName',
        );
      },
      onDownloadError: (errorMessage) {
        if (mounted) {
          setState(() => _isDownloading[index] = false);
        }
        _showSnack("Error", "Failed to download file", Colors.red);
      },
    );
  }

  void _showSnack(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // 🆕 search bar widget (subject/remarks/class/section pe filter)
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search by subject, remarks, class or section...",
          hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: sylMaroonShade700),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final allList = controller.syllabusList.toList();

        // 🆕 local search filter
        final list = _searchQuery.isEmpty
            ? allList
            : allList.where((item) {
          final subjectName = (item.subjectName ?? '').toLowerCase();
          final className = (item.className ?? '').toLowerCase();
          final sectionName = (item.sectionName ?? '').toLowerCase();
          final remarks = (item.remarks ?? '').toLowerCase();
          return subjectName.contains(_searchQuery) ||
              className.contains(_searchQuery) ||
              sectionName.contains(_searchQuery) ||
              remarks.contains(_searchQuery);
        }).toList();

        if (allList.isEmpty) {
          return const Center(child: Text('No syllabus data found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            Expanded(
              child: list.isEmpty
                  ? Center(
                child: Text(
                  'No matching syllabus',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600),
                ),
              )
                  : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];

                  final downloading = _isDownloading[index] ?? false;
                  final progress = _downloadProgress[index] ?? 0.0;

                  final subjectName = item.subjectName ?? 'N/A';
                  final className = item.className ?? 'N/A';
                  final sectionName = item.sectionName ?? 'N/A';
                  final remarks = item.remarks ?? 'No remarks';
                  final date = formatDate(item.createDate ?? '');

                  final hasFile =
                  (item.syllabusFile?.isNotEmpty ?? false);
                  final fileUrl = hasFile
                      ? Uri.encodeFull(
                    '${AppUrl.base_url}${AppUrl.syllabusDownloadUrl}${item.syllabusFile}',
                  )
                      : '';
                  final fileName = hasFile
                      ? (item.syllabusFile!.split('/').last)
                      : 'syllabus_${DateTime.now().millisecondsSinceEpoch}.pdf';

                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 34.r,
                                width: 34.r,
                                decoration: BoxDecoration(
                                  color: sylMaroonShade50,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.menu_book,
                                  color: sylMaroonShade700,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'Syllabus: $subjectName',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Date: $date",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            remarks,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Divider(color: Colors.grey.shade300, height: 1),
                          SizedBox(height: 10.h),
                          Text(
                            'Class: $className',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Section: $sectionName',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasFile) ...[
                            SizedBox(height: 12.h),
                            Divider(color: Colors.grey.shade200, height: 1),
                            SizedBox(height: 10.h),
                            if (downloading)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey.shade200,
                                    color: sylMaroon,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Downloading ${(progress * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                        fontSize: 12.sp, color: sylMaroon),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _downloadAndShare(
                                        url: fileUrl,
                                        fileName: fileName,
                                        index: index,
                                        subjectName: subjectName,
                                        className: className,
                                        sectionName: sectionName,
                                        remarks: remarks,
                                        date: date,
                                      );
                                    },
                                    icon: const Icon(Icons.download, size: 18),
                                    label: const Text("Download & Share"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: sylMaroon,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w, vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.r),
                                      ),
                                      textStyle: TextStyle(fontSize: 13.sp),
                                    ),
                                  ),
                                ],
                              ),
                          ] else ...[
                            SizedBox(height: 8.h),
                            Text(
                              "No file attached",
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

String formatDate(String date) {
  try {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return "";
  }
}