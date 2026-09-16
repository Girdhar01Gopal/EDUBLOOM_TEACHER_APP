import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/event_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';

// ✅ Axis Bank brand color
const Color kAxisMaroon = Color(0xFF97144D);
const Color kAxisMaroonShade50 = Color(0xFFF3E0E9);
const Color kAxisMaroonShade300 = Color(0xFFC0568C);

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

          // 🆕 CHANGED: dropdown -> horizontal multi-select chips (Notification jaisa hi)
          _classMultiSelect(),
          SizedBox(height: 16.h),

          _sectionMultiSelect(),
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

          SizedBox(
            width: double.infinity,
            child: Container(
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
                onPressed: () => controller.registerEvent(),
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
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade700,
      letterSpacing: 0.3,
    ),
  );

  // 🆕 NEW: horizontal scrollable multi-select chips for Class (Notification jaisa hi)
  Widget _classMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("Select Class (Multiple)"),
        SizedBox(height: 8.h),
        SizedBox(
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
                  controller.selectedClassIds.contains(cls.classId);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isSelected) {
                        controller.selectedClassIds.remove(cls.classId);
                      } else {
                        controller.selectedClassIds.add(cls.classId!);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kAxisMaroon
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? kAxisMaroon
                              : Colors.grey.shade300,
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
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
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
        ),
      ],
    );
  }

  // 🆕 NEW: horizontal scrollable multi-select chips for Section (Notification jaisa hi)
  Widget _sectionMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("Select Section (Multiple)"),
        SizedBox(height: 8.h),
        SizedBox(
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
                      if (isSelected) {
                        controller.selectedSectionIds.remove(sec.sectionId);
                      } else {
                        controller.selectedSectionIds.add(sec.sectionId!);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kAxisMaroon
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? kAxisMaroon
                              : Colors.grey.shade300,
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
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
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
        ),
      ],
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

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  // 🆕 ADDED: search bar state (Notification jaisa hi)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller.fetchVEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // ✅ flutter_file_downloader se download — Notification Page jaisa same logic
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

        _showSnack(
            "Downloaded ✓", "Saved to Downloads folder", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));

        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Event – $eventName',
          text:
          '📅 Event: $eventName\n📍 Place: $eventPlace\n📝 Description: $description\n🗓️ Date: $eventDate',
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

  // 🆕 ADDED: search bar widget (title / place / message pe filter)
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
          hintText: "Search by event name, place or description...",
          hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: kAxisMaroon),
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

        final allEvents = controller.eventList.toList()
          ..sort(
                  (a, b) => (b.createDate ?? '').compareTo(a.createDate ?? ''));

        // 🆕 ADDED: local search filter — eventName/eventPlace/description/createBy
        final events = _searchQuery.isEmpty
            ? allEvents
            : allEvents.where((item) {
          final name = (item.eventName ?? '').toLowerCase();
          final place = (item.eventPlace ?? '').toLowerCase();
          final desc = (item.description ?? '').toLowerCase();
          final by = (item.createBy ?? '').toLowerCase();
          return name.contains(_searchQuery) ||
              place.contains(_searchQuery) ||
              desc.contains(_searchQuery) ||
              by.contains(_searchQuery);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            Expanded(
              child: events.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      allEvents.isEmpty
                          ? Icons.event_busy_outlined
                          : Icons.search_off_rounded,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      allEvents.isEmpty
                          ? 'No data found'
                          : 'No matching events',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
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
                                  "${AppUrl.base_url}${AppUrl.eventDownloadUrl}$pic",                                  width: 100.w,
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                    Text('Class: ${item.className ?? 'N/A'} - ${item.sectionName ?? 'N/A'}',
                                        style: TextStyle(fontSize: 12.sp, color: Colors.teal.shade700)),
                                    SizedBox(height: 4.h),
                                    Text('Desc: ${item.description ?? 'N/A'}',
                                        style: TextStyle(fontSize: 12.sp)),
                                    SizedBox(height: 6.h),
                                    Text(
                                        'Date: ${formatDate(item.eventDate)}',
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
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
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
                                          "${AppUrl.base_url}${AppUrl.eventDownloadUrl}$pic";
                                      _downloadAndShare(
                                        url: fileUrl,
                                        fileName: pic,
                                        index: index,
                                        eventName: item.eventName ?? 'N/A',
                                        eventPlace: item.eventPlace ?? 'N/A',
                                        description:
                                        item.description ?? 'N/A',
                                        eventDate:
                                        formatDate(item.eventDate),
                                        createdBy: createdByText,
                                      );
                                    },
                                    icon:
                                    const Icon(Icons.download, size: 18),
                                    label: const Text("Download & Share"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kAxisMaroon,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.r),
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
              ),
            ),
          ],
        );
      }),
    );
  }
}