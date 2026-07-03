import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/note_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';

const Color axisMaroon = Color(0xFF97144D);
const Color axisMaroonShade50 = Color(0xFFF3E0E9);
const Color axisMaroonShade300 = Color(0xFFC0568C);
const Color axisMaroonShade400 = Color(0xFFAE3B77);
const Color axisMaroonShade600 = Color(0xFFA61856);
const Color axisMaroonShade700 = Color(0xFF97144D);
const Color axisMaroonShade800 = Color(0xFF800F40);

class NoteScreen extends GetView<NoteController> {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: axisMaroonShade800,
          title: const Text(
            "📝 Notes",
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
                icon: Icon(Icons.note_add, color: Colors.white),
                text: "Add Note",
              ),
              Tab(
                icon: Icon(Icons.notes, color: Colors.white),
                text: "View Notes",
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            AddNoteTab(),
            ViewNoteTab(),
          ],
        ),
      ),
    );
  }
}

// ========================== ADD NOTE TAB ==========================
class AddNoteTab extends GetView<NoteController> {
  const AddNoteTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          // Class Dropdown
          Obx(
                () => DropdownButtonFormField<ListDataa>(
              value: controller.listDataa
                  .contains(controller.selectedClass.value)
                  ? controller.selectedClass.value
                  : null,
              items: controller.listDataa
                  .map(
                    (item) => DropdownMenuItem<ListDataa>(
                  value: item,
                  child: Text(item.className ?? ''),
                ),
              )
                  .toList(),
              onChanged: controller.setSelectedClass,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Section Dropdown
          Obx(
                () => DropdownButtonFormField<ListDatta>(
              value: controller.sectionList
                  .contains(controller.selectedSection.value)
                  ? controller.selectedSection.value
                  : null,
              items: controller.sectionList
                  .map(
                    (item) => DropdownMenuItem<ListDatta>(
                  value: item,
                  child: Text(item.section ?? ''),
                ),
              )
                  .toList(),
              onChanged: controller.setSelectedSection,
              decoration: const InputDecoration(
                labelText: 'Select Section',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 16.h),


          // Subject Dropdown
          Obx(
                () => DropdownButtonFormField<ListDaataa>(
              value: controller.subjectlist
                  .contains(controller.selectsubject.value)
                  ? controller.selectsubject.value
                  : null,
              items: controller.subjectlist
                  .map(
                    (item) => DropdownMenuItem<ListDaataa>(
                  value: item,
                  child: Text(item.subject ?? ''),
                ),
              )
                  .toList(),
              onChanged: (val) {
                controller.setsubject(val);
                controller.subject.value = val?.subjectId ?? 0;
              },
              decoration: const InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Remarks
          TextField(
            decoration: const InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => controller.remarks.value = value,
          ),
          SizedBox(height: 16.h),

          // File Picker
          _buildFilePicker(context),
          SizedBox(height: 24.h),

          // Submit Button
          Container(
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
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onPressed: () => controller.registerNote(
                controller.selectedClass.value?.classId ?? 0,
                controller.selectedSection.value?.sectionId ?? 0,
                controller.selectsubject.value?.subjectId ?? 0,
                controller.remarks.value,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Note File (Image / PDF)",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final file = controller.imageFile.value;
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
                  Icon(Icons.add_circle_outline,
                      size: 40.sp, color: axisMaroonShade400),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap to select file",
                    style: TextStyle(
                        fontSize: 14.sp, color: axisMaroonShade600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Camera • Gallery • PDF",
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }),

        // Remove file button
        Obx(() => controller.imageFile.value != null
            ? Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => controller.imageFile.value = null,
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
          Text(
            "PDF Selected ✓",
            style:
            TextStyle(fontSize: 12.sp, color: Colors.green.shade600),
          ),
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
                child: const Text(
                  "Image Selected ✓",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
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
              Text(
                "Select File From",
                style:
                TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                          source: ImageSource.camera, imageQuality: 80);
                      if (photo != null) {
                        controller.imageFile.value = File(photo.path);
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
                          source: ImageSource.gallery, imageQuality: 80);
                      if (photo != null) {
                        controller.imageFile.value = File(photo.path);
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
                        controller.imageFile.value =
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
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style:
            TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ========================== VIEW NOTE TAB ==========================
class ViewNoteTab extends StatefulWidget {
  const ViewNoteTab({super.key});

  @override
  State<ViewNoteTab> createState() => _ViewNoteTabState();
}

class _ViewNoteTabState extends State<ViewNoteTab> {
  final NoteController controller = Get.find<NoteController>();
  final Dio dio = Dio();

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  @override
  void initState() {
    super.initState();
    controller.fetchVNotes();
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  ListDataa? _findClassById(dynamic classId) {
    try {
      return controller.listDataa.firstWhere((c) => c.classId == classId);
    } catch (_) {
      return null;
    }
  }

  ListDatta? _findSectionById(dynamic sectionId) {
    try {
      return controller.sectionList.firstWhere((s) => s.sectionId == sectionId);
    } catch (_) {
      return null;
    }
  }

  ListDaataa? _findSubjectById(dynamic subjectId) {
    try {
      return controller.subjectlist.firstWhere((s) => s.subjectId == subjectId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _downloadAndShare({
    required String url,
    required String fileName,
    required int index,
    required String className,
    required String sectionName,
    required String subjectName,
    required String remarks,
    required String date,
  }) async {
    try {
      setState(() {
        _isDownloading[index] = true;
        _downloadProgress[index] = 0;
      });

      // ✅ device_info_plus se SDK version lena — 100% reliable
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        final sdkInt = info.version.sdkInt;

        if (sdkInt >= 33) {
          // Android 13+ — koi permission nahi chahiye
        } else if (sdkInt >= 30) {
          // Android 11 & 12
          final status = await Permission.manageExternalStorage.status;
          if (!status.isGranted) {
            final result = await Permission.manageExternalStorage.request();
            if (!result.isGranted) {
              _showSnack("Permission Denied",
                  "Storage permission is required to download.", Colors.red);
              setState(() => _isDownloading[index] = false);
              return;
            }
          }
        } else {
          // Android 10 aur neeche
          final status = await Permission.storage.status;
          if (!status.isGranted) {
            final result = await Permission.storage.request();
            if (!result.isGranted) {
              _showSnack("Permission Denied",
                  "Storage permission is required to download.", Colors.red);
              setState(() => _isDownloading[index] = false);
              return;
            }
          }
        }
      }

      // ✅ Save directory
      Directory saveDir;
      if (Platform.isAndroid) {
        final downloads = Directory('/storage/emulated/0/Download/Notes');
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        saveDir = downloads;
      } else {
        final appDocs = await getApplicationDocumentsDirectory();
        saveDir = Directory('${appDocs.path}/Notes');
        if (!await saveDir.exists()) {
          await saveDir.create(recursive: true);
        }
      }

      // ✅ Clean file name
      final cleanName = fileName.toLowerCase().endsWith('.pdf')
          ? fileName
          : '$fileName.pdf';
      final savePath = '${saveDir.path}/$cleanName';

      // ✅ Download with progress
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress[index] = received / total;
            });
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (mounted) {
        setState(() {
          _isDownloading[index] = false;
          _downloadProgress[index] = 1.0;
        });

        _showSnack(
            "Downloaded ✓", "Saved to Downloads/Notes folder", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));

        await Share.shareXFiles(
          [XFile(savePath)],
          subject: 'Note – $subjectName',
          text: '📚 Subject: $subjectName\n'
              '🏫 Class: $className\n'
              '📋 Section: $sectionName\n'
              '📝 Remarks: $remarks\n'
              '🗓️ Date: $date',
        );
      }
    } catch (e) {
      debugPrint("Download Error: $e");
      if (mounted) {
        setState(() => _isDownloading[index] = false);
        _showSnack("Error", "Failed to download: $e", Colors.red);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.listData.isEmpty) {
          return const Center(child: Text('No notes found'));
        } else {
          return ListView.builder(
            itemCount: controller.listData.length,
            itemBuilder: (context, index) {
              final item = controller.listData[index];

              final classItem = _findClassById(item.classId);
              final sectionItem = _findSectionById(item.sectionId);
              final subjectItem = _findSubjectById(item.subjectId);

              final className = classItem?.className ?? 'N/A';
              final sectionName = sectionItem?.section ?? 'N/A';
              final subjectName = subjectItem?.subject ?? 'N/A';
              final remarks = item.remarks ?? 'No Remarks';
              final date = formatDate(item.createDate ?? '');

              final downloading = _isDownloading[index] ?? false;
              final progress = _downloadProgress[index] ?? 0.0;

              final hasFile =
                  item.notesFile != null && item.notesFile!.isNotEmpty;

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
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 34.r,
                            width: 34.r,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.menu_book,
                              color: Colors.purple.shade700,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Note: $subjectName',
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

                      // Download section
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
                              ElevatedButton.icon(
                                onPressed: () {
                                  final fileUrl =
                                      "https://playschool.edubloom.in/Upload/Notification/Images/${item.notesFile}";
                                  final fileName = item.notesFile!
                                      .toLowerCase()
                                      .endsWith('.pdf')
                                      ? item.notesFile!
                                      : '${item.notesFile}.pdf';

                                  _downloadAndShare(
                                    url: fileUrl,
                                    fileName: fileName,
                                    index: index,
                                    className: className,
                                    sectionName: sectionName,
                                    subjectName: subjectName,
                                    remarks: remarks,
                                    date: date,
                                  );
                                },
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text("Download & Share"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: axisMaroonShade700,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
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
          );
        }
      }),
    );
  }
}