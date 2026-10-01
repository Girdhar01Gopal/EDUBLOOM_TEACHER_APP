import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/curriculum controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../res/app_url.dart';

const String kCurriculumFileBasePath = 'Upload/Curriculum/';

// 🎨 CHANGED: teal -> maroon (Notification jaisa hi)
const Color axisMaroon = Color(0xFF97144D);
const Color axisMaroonShade50 = Color(0xFFF3E0E9);
const Color axisMaroonShade300 = Color(0xFFC0568C);
const Color axisMaroonShade700 = Color(0xFF97144D);
const Color axisMaroonShade800 = Color(0xFF800F40);

class CurriculumScreen extends GetView<CurriculumController> {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: axisMaroonShade800,
          title: const Text(
            "📚 Curriculum",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: Get.back,
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(icon: Icon(Icons.add), text: "Add Curriculum"),
              Tab(icon: Icon(Icons.view_list), text: "View Curriculum"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddCurriculumTab(),
            ViewCurriculumTab(),
          ],
        ),
      ),
    );
  }
}

// ========================== ADD CURRICULUM TAB ==========================
class AddCurriculumTab extends StatefulWidget {
  const AddCurriculumTab({super.key});

  @override
  State<AddCurriculumTab> createState() => _AddCurriculumTabState();
}

class _AddCurriculumTabState extends State<AddCurriculumTab> {
  final controller = Get.find<CurriculumController>();

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
              Text(
                "Select File From",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
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
                      if (result != null && result.files.single.path != null) {
                        controller.pdfFile.value =
                            File(result.files.single.path!);
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
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFilePreview(File file) {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    if (isPdf) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 54.sp, color: Colors.red.shade400),
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
              style: TextStyle(fontSize: 12.sp, color: Colors.green.shade600)),
        ],
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              file,
              fit: BoxFit.cover,
              cacheWidth: 800,
              filterQuality: FilterQuality.medium,
            ),
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  // ── Helpers ──────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade700,
      letterSpacing: 0.3,
    ),
  );

  Widget _multiSelectHeader(String label,
      {required VoidCallback onSelectAll, required VoidCallback onClear}) {
    return Row(
      children: [
        Expanded(child: _sectionLabel(label)),
        GestureDetector(
          onTap: onSelectAll,
          child: Text('Select all',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: axisMaroonShade700)),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onClear,
          child: Text('Clear',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500)),
        ),
      ],
    );
  }

  // 🆕 NEW: horizontal scrollable multi-select chips for Class (Notification jaisa hi)
  Widget _classMultiSelect() {
    return SizedBox(
      height: 42.h,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.classList.isEmpty) {
          return Text(
            "No classes found",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          );
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.classList.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final cls = controller.classList[index];
            return Obx(() {
              final isSelected =
              controller.selectedClasses.any((c) => c.classId == cls.classId);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.toggleClassSelection(cls),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? axisMaroon : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? axisMaroon : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle, size: 14.sp, color: Colors.white),
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

  // 🆕 NEW: horizontal scrollable multi-select chips for Section (Notification jaisa hi)
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
              final isSelected = controller.selectedSections
                  .any((s) => s.sectionId == sec.sectionId);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.toggleSectionSelection(sec),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? axisMaroon : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? axisMaroon : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle, size: 14.sp, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Curriculum Name (maps to "CurriculumName" in API)
          TextField(
            controller:
            TextEditingController(text: controller.curriculumName.value)
              ..selection = TextSelection.collapsed(
                  offset: controller.curriculumName.value.length),
            decoration: InputDecoration(
              labelText: 'Curriculum Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: axisMaroonShade700, width: 1.5),
              ),
            ),
            onChanged: (val) => controller.curriculumName.value = val,
          ),
          SizedBox(height: 16.h),

          // Session Dropdown (Dynamic API)
          Obx(
                () => DropdownButtonFormField<dynamic>(
              value: controller.selectedSession.value,
              hint: const Text("Select Session"),
              isExpanded: true,
              onChanged: (newVal) => controller.setSelectedSession(newVal),
              items: controller.sessionList.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.session ?? 'No session'),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Session',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ✅ Class Multi-select (horizontal scrollable chips — Notification jaisa hi)
          _multiSelectHeader('Select Class (Multiple)', onSelectAll: () {
            for (final c in controller.classList) {
              if (!controller.selectedClasses
                  .any((s) => s.classId == c.classId)) {
                controller.toggleClassSelection(c);
              }
            }
          }, onClear: () {
            controller.selectedClasses.clear();
          }),
          SizedBox(height: 8.h),
          _classMultiSelect(),
          SizedBox(height: 16.h),

          // ✅ Section Multi-select (horizontal scrollable chips — Notification jaisa hi)
          _multiSelectHeader('Select Section (Multiple)', onSelectAll: () {
            for (final s in controller.sectionList) {
              if (!controller.selectedSections
                  .any((x) => x.sectionId == s.sectionId)) {
                controller.toggleSectionSelection(s);
              }
            }
          }, onClear: () {
            controller.selectedSections.clear();
          }),
          SizedBox(height: 8.h),
          _sectionMultiSelect(),
          SizedBox(height: 16.h),

          // ⚠️ Info banner: multiple selections ke case mein alag-alag curriculum banenge
          Obx(() {
            final classCount = controller.selectedClasses.length;
            final sectionCount = controller.selectedSections.length;

            if (classCount <= 1 && sectionCount <= 1) return const SizedBox();

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18.sp, color: Colors.amber.shade800),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "This curriculum will be linked to $classCount class(es) and $sectionCount section(s).",
                      style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            );
          }),

          TextField(
            controller: TextEditingController(text: controller.description.value)
              ..selection = TextSelection.collapsed(
                  offset: controller.description.value.length),
            decoration: InputDecoration(
              labelText: 'Description',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: axisMaroonShade700, width: 1.5),
              ),
            ),
            onChanged: (val) => controller.description.value = val,
          ),
          SizedBox(height: 16.h),

          _sectionLabel("Curriculum File (Image / PDF)"),
          SizedBox(height: 8.h),
          Obx(() {
            final file = controller.pdfFile.value;
            return GestureDetector(
              onTap: () => _showPickerOptions(context),
              child: Container(
                height: 160.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: axisMaroonShade300, width: 1.5),
                  borderRadius: BorderRadius.circular(12.r),
                  color: axisMaroonShade50,
                ),
                child: file != null
                    ? _buildFilePreview(file)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 40.sp, color: axisMaroonShade700),
                    SizedBox(height: 8.h),
                    Text("Tap to select file",
                        style: TextStyle(
                            fontSize: 14.sp, color: axisMaroonShade800)),
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
              },
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 18),
              label: const Text("Remove",
                  style: TextStyle(color: Colors.red)),
            ),
          )
              : const SizedBox()),

          SizedBox(height: 24.h),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: Obx(
                  () => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: controller.isSubmitting.value
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    controller.isSubmitting.value
                        ? "Submitting..."
                        : "Submit Curriculum",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.registerCurriculum,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                    EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ========================== VIEW CURRICULUM TAB ==========================
class ViewCurriculumTab extends StatefulWidget {
  const ViewCurriculumTab({super.key});

  @override
  State<ViewCurriculumTab> createState() => _ViewCurriculumTabState();
}

class _ViewCurriculumTabState extends State<ViewCurriculumTab> {
  final controller = Get.find<CurriculumController>();

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurriculum();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isImageFile(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  String _mimeTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }

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

    await FileDownloader.downloadFile(
      url: url,
      name: fileName,
      notificationType: NotificationType.all,
      onProgress: (name, progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[index] = (progress ?? 0) / 100;
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

        _showSnack(
            "Downloaded ✓", "File downloaded successfully", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));

        await Share.shareXFiles(
          [XFile(path, mimeType: _mimeTypeFor(fileName))],
          subject: 'Curriculum – $subjectName',
          text:
          '📚 Subject: $subjectName\n🏫 Class: $className\n📋 Section: $sectionName\n📝 Remarks: $remarks\n🗓️ Date: $date',
        );
      },
      onDownloadError: (errorMessage) {
        if (kDebugMode) {
          print("Download Error: $errorMessage");
        }
        if (mounted) {
          setState(() => _isDownloading[index] = false);
        }
        _showSnack("Error", "Failed to download: $errorMessage", Colors.red);
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

  // 🆕 search bar widget (subject / class / section / description pe filter)
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search by class, section, curriculum, description...',
          hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: axisMaroonShade700),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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

        final allData = controller.curriculumList;

        final data = _query.isEmpty
            ? allData
            : allData.where((item) {
          final curriculumName = (item.curriculumName ?? '').toLowerCase();
          final className = (item.className ?? '').toLowerCase();
          final sectionName = (item.section ?? '').toLowerCase();
          final description = (item.description ?? '').toLowerCase();
          return curriculumName.contains(_query) ||
              className.contains(_query) ||
              sectionName.contains(_query) ||
              description.contains(_query);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            Expanded(
              child: data.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      allData.isEmpty
                          ? Icons.menu_book_outlined
                          : Icons.search_off_rounded,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      allData.isEmpty
                          ? 'No curriculum found'
                          : 'No matching curriculum',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchCurriculum();
                },
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];

                    final downloading = _isDownloading[index] ?? false;
                    final progress = _downloadProgress[index] ?? 0.0;

                    final subjectName = item.curriculumName ?? 'N/A';
                    final className = item.className ?? 'N/A';
                    final sectionName = item.section ?? 'N/A';
                    final remarks = item.description ?? 'No remarks';
                    final date = formatDate(item.createDate ?? '');

                    final hasFile = (item.pdfFileName?.isNotEmpty ?? false);
                    final fileUrl = hasFile
                        ? Uri.encodeFull(
                      '${AppUrl.base_url}$kCurriculumFileBasePath${item.pdfFileName}',
                    )
                        : '';
                    final fileName = hasFile
                        ? item.pdfFileName!
                        : 'curriculum_${DateTime.now().millisecondsSinceEpoch}.pdf';
                    final isImage = hasFile && _isImageFile(item.pdfFileName!);
                    final isActive = item.action == "1";

                    return Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
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
                                    color: axisMaroonShade50,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: axisMaroonShade700,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'Curriculum: $subjectName',
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.shade200,
                                      color: axisMaroon,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      "Downloading ${(progress * 100).toStringAsFixed(0)}%",
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: axisMaroonShade700),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // ── Active / Inactive toggle button ──
                                    InkWell(
                                      borderRadius: BorderRadius.circular(10.r),
                                      onTap: () {
                                        controller.toggleCurriculumStatus(
                                            item.curriculumId ?? 0);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.shade600
                                              : Colors.red.shade600,
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isActive
                                                  ? Icons.toggle_on
                                                  : Icons.toggle_off,
                                              size: 18.sp,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              isActive ? "Active" : "Inactive",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // ── Download & Share button ──
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
                                      icon: Icon(
                                          isImage
                                              ? Icons.download
                                              : Icons.picture_as_pdf,
                                          size: 18),
                                      label: const Text("Download & Share"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: axisMaroonShade700,
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
            ),
          ],
        );
      }),
    );
  }
}

String formatDate(String date) {
  if (date.isEmpty) return "N/A";
  try {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return "N/A";
  }
}