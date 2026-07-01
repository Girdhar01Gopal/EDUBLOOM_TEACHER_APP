import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/event_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);

class EventScreen extends GetView<EventController> {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: kAxisMaroon,
          title: const Text(
            "📝Upcoming Events",
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
                icon: Icon(Icons.event, color: Colors.white),
                text: "Add Event",
              ),
              Tab(
                icon: Icon(Icons.view_list, color: Colors.white),
                text: "View Event",
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            AddEventTab(),
            ViewEventTab(),
          ],
        ),
      ),
    );
  }
}

// ========================== ADD EVENT TAB ==========================
class AddEventTab extends StatefulWidget {
  const AddEventTab({super.key});

  @override
  State<AddEventTab> createState() => _AddEventTabState();
}

class _AddEventTabState extends State<AddEventTab> {
  final EventController controller = Get.find<EventController>();
  late final TextEditingController eventDateCtrl;
  Worker? _dateWorker;

  @override
  void initState() {
    super.initState();
    eventDateCtrl = TextEditingController(text: controller.getDisplayDate());
    _dateWorker = ever(controller.eventDate, (_) {
      eventDateCtrl.text = controller.getDisplayDate();
    });
  }

  @override
  void dispose() {
    _dateWorker?.dispose();
    eventDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField('Event Name', controller.eventName),
          SizedBox(height: 16.h),

          Obx(
                () => DropdownButtonFormField<ListDataa>(
              value: controller.selectedClass.value,
              items: controller.listDataa
                  .map(
                    (item) => DropdownMenuItem<ListDataa>(
                  value: item,
                  child: Text(item.className ?? ''),
                ),
              )
                  .toList(),
              onChanged: (val) => controller.setSelectedClass(val),
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Obx(
                () => DropdownButtonFormField<ListDatta?>(
              value: controller.selectedSection.value,
              isExpanded: true,
              hint: const Text('Select Section'),
              items: [
                const DropdownMenuItem<ListDatta?>(
                  value: null,
                  child: Text(
                    'Select Section',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ...controller.sectionList.map(
                      (item) => DropdownMenuItem<ListDatta?>(
                    value: item,
                    child: Text(item.section ?? ''),
                  ),
                ),
              ],
              onChanged: (ListDatta? newVal) {
                controller.setSelectedSection(newVal);
                controller.section.value =
                    newVal?.sectionId.toString() ?? '';
              },
              decoration: const InputDecoration(
                labelText: 'Select Section',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null) return 'Section is required';
                return null;
              },
            ),
          ),
          SizedBox(height: 16.h),

          GestureDetector(
            onTap: () => controller.pickDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: eventDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          _inputField('Description', controller.description),
          SizedBox(height: 16.h),
          _inputField('Event Place', controller.eventPlace),
          SizedBox(height: 20.h),

          _buildImagePicker(
            label: 'Event Image',
            imageFile: controller.imageFile,
          ),
          SizedBox(height: 24.h),

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
              onPressed: () {
                controller.registerEvent(
                  controller.eventName.value,
                  controller.selectedSection.value?.sectionId ?? 0,
                  controller.getApiDate(),
                  controller.eventPlace.value,
                  controller.description.value,
                  controller.selectedClass.value?.classId.toString() ?? '',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _inputField(String label, RxString controllerValue) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (val) => controllerValue.value = val,
    );
  }

  Widget _buildImagePicker({
    required String label,
    required Rx<File?> imageFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Obx(() {
          final file = imageFile.value;
          return GestureDetector(
            onTap: () => _showImageSourceSheet(imageFile),
            child: Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: kAxisMaroon.withOpacity(0.4), width: 1.5),
                borderRadius: BorderRadius.circular(12.r),
                color: kAxisMaroon.withOpacity(0.05),
              ),
              child: file != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11.r),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Image Selected ✓",
                          style: TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40.sp, color: kAxisMaroon.withOpacity(0.6)),
                  SizedBox(height: 8.h),
                  Text("Tap to select image",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: kAxisMaroon.withOpacity(0.8))),
                  SizedBox(height: 4.h),
                  Text("Camera • Gallery",
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
        }),
        Obx(() => imageFile.value != null
            ? Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              imageFile.value = null;
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

  void _showImageSourceSheet(Rx<File?> imageFile) {
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
              Text("Select Image From",
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
                        imageFile.value = File(photo.path);
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
                        imageFile.value = File(photo.path);
                        controller.file.value = photo.path;
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

// ========================== VIEW EVENT TAB ==========================
class ViewEventTab extends StatefulWidget {
  const ViewEventTab({super.key});

  @override
  State<ViewEventTab> createState() => _ViewEventTabState();
}

class _ViewEventTabState extends State<ViewEventTab> {
  final EventController controller = Get.find<EventController>();
  final Dio dio = Dio();

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  @override
  void initState() {
    super.initState();
    controller.fetchVEvents();
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "N/A";
    }
  }

  // ✅ FIXED: device_info_plus se SDK version
  Future<void> _downloadAndShare({
    required String url,
    required String fileName,
    required int index,
    required String eventName,
    required String eventPlace,
    required String description,
    required String eventDate,
    required String createdBy,
  }) async {
    try {
      setState(() {
        _isDownloading[index] = true;
        _downloadProgress[index] = 0;
      });

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
                  "Storage permission is required.", Colors.red);
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
                  "Storage permission is required.", Colors.red);
              setState(() => _isDownloading[index] = false);
              return;
            }
          }
        }
      }

      Directory saveDir;
      if (Platform.isAndroid) {
        final downloads =
        Directory('/storage/emulated/0/Download/Events');
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        saveDir = downloads;
      } else {
        final appDocs = await getApplicationDocumentsDirectory();
        saveDir = Directory('${appDocs.path}/Events');
        if (!await saveDir.exists()) {
          await saveDir.create(recursive: true);
        }
      }

      final savePath = '${saveDir.path}/$fileName';
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
            "Downloaded ✓", "Saved to Downloads/Events folder", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));

        await Share.shareXFiles(
          [XFile(savePath)],
          subject: 'Event – $eventName',
          text:
          '📅 Event: $eventName\n📍 Place: $eventPlace\n📝 Description: $description\n🗓️ Date: $eventDate',
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
        }

        if (controller.eventList.isEmpty) {
          return const Center(child: Text('No data found'));
        }

        final events = controller.eventList.toList()
          ..sort(
                  (a, b) => (b.createDate ?? '').compareTo(a.createDate ?? ''));

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final item = events[index];

            final createdBy = (item.createBy ?? '').trim();
            final createdByText = createdBy.isEmpty ? 'N/A' : createdBy;

            final pic = (item.eventPic ?? '').trim();
            final hasPic = pic.isNotEmpty;

            final downloading = _isDownloading[index] ?? false;
            final progress = _downloadProgress[index] ?? 0.0;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: hasPic
                              ? Image.network(
                            "https://playschool.edubloom.in/Upload/Event/Images/$pic",
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100.w,
                              height: 100.h,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.white, size: 40),
                            ),
                          )
                              : Container(
                            width: 100.w,
                            height: 100.h,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image,
                                color: Colors.white, size: 40),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.eventName ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text('Place: ${item.eventPlace ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14.sp)),
                              SizedBox(height: 4.h),
                              Text('Desc: ${item.description ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12.sp)),
                              SizedBox(height: 6.h),
                              Text('Date: ${formatDate(item.eventDate)}',
                                  style: TextStyle(fontSize: 12.sp)),
                              SizedBox(height: 4.h),
                              Text('Created By: $createdByText',
                                  style: TextStyle(fontSize: 12.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (hasPic) ...[
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
                              color: kAxisMaroon,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Downloading ${(progress * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: kAxisMaroon),
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
                                    "https://playschool.edubloom.in/Upload/Event/Images/$pic";
                                _downloadAndShare(
                                  url: fileUrl,
                                  fileName: pic,
                                  index: index,
                                  eventName: item.eventName ?? 'N/A',
                                  eventPlace: item.eventPlace ?? 'N/A',
                                  description: item.description ?? 'N/A',
                                  eventDate: formatDate(item.eventDate),
                                  createdBy: createdByText,
                                );
                              },
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text("Download & Share"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAxisMaroon,
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
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}