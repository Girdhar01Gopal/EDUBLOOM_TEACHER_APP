import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/notification_controller.dart';
import '../models/sectionmodel.dart';
import '../models/class_list_model.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';

const Color axisMaroon = Color(0xFF97144D);
const Color axisMaroonShade50 = Color(0xFFF3E0E9);
const Color axisMaroonShade300 = Color(0xFFC0568C);
const Color axisMaroonShade700 = Color(0xFF97144D);
const Color axisMaroonShade800 = Color(0xFF800F40);

// ─────────────────────────────────────────────
//  ROOT SCREEN
// ─────────────────────────────────────────────
class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: axisMaroonShade800,
          title: const Text(
            "🔔 Notifications",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
            TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(icon: Icon(Icons.add_alert), text: "Add Notification"),
              Tab(icon: Icon(Icons.view_list), text: "View Notification"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddNotificationTab(),
            AllNotificationTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ADD NOTIFICATION TAB
// ─────────────────────────────────────────────
class AddNotificationTab extends GetView<NotificationController> {
  const AddNotificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Title'),
          SizedBox(height: 6.h),
          _textField('Enter notification title', controller.title),
          SizedBox(height: 16.h),

          _sectionLabel('Message'),
          SizedBox(height: 6.h),
          _textField('Enter notification message', controller.message,
              maxLines: 3),
          SizedBox(height: 16.h),

          // 🆕 CHANGED: dropdown -> horizontal multi-select chips (Galaryvideo jaisa hi)
          _classMultiSelect(),
          SizedBox(height: 16.h),

          _sectionMultiSelect(),
          SizedBox(height: 16.h),

          // _datePicker(label: 'Create Date', isCreate: true),
          // SizedBox(height: 16.h),
          // _datePicker(label: 'Update Date', isCreate: false),
          // SizedBox(height: 16.h),

          _sectionLabel('Notification Image'),
          SizedBox(height: 6.h),
          _buildImagePicker(imageFile: controller.imageFile),
          SizedBox(height: 28.h),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: Container(
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
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Submit Notification',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                onPressed: () => controller.registerNote(),
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
          SizedBox(height: 24.h),
        ],
      ),
    );
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

  Widget _textField(String hint, RxString value, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
      onChanged: (val) => value.value = val,
    );
  }

  // 🆕 NEW: horizontal scrollable multi-select chips for Class (Galaryvideo jaisa hi)
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
                            ? axisMaroon
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? axisMaroon
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

  // 🆕 NEW: horizontal scrollable multi-select chips for Section (Galaryvideo jaisa hi)
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
                            ? axisMaroon
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? axisMaroon
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

  Widget _datePicker({required String label, required bool isCreate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => controller.pickDate(Get.context!, isCreate),
          child: Obx(
                () => Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 18, color: axisMaroonShade700),
                  SizedBox(width: 10.w),
                  Text(
                    controller.getFormattedDate(isCreate
                        ? controller.createDate.value
                        : controller.updateDate.value),
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker({required Rx<File?> imageFile}) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(imageFile),
      child: Obx(
            () => Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: imageFile.value != null
                  ? axisMaroonShade300
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: imageFile.value != null
              ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: Image.file(
                  imageFile.value!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _overlayBtn(
                      icon: Icons.edit_rounded,
                      color: axisMaroon,
                      onTap: () => _showImageSourceSheet(imageFile),
                    ),
                    SizedBox(width: 6.w),
                    _overlayBtn(
                      icon: Icons.delete_rounded,
                      color: Colors.red,
                      onTap: () {
                        imageFile.value = null;
                        controller.notificationFile.value = '';
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 40, color: Colors.grey.shade400),
              SizedBox(height: 10.h),
              Text(
                'Tap to add image',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                'Camera or Gallery',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overlayBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _showImageSourceSheet(Rx<File?> imageFileTarget) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Image Source',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.pickImage(
                        imageFileTarget, ImageSource.camera);
                  },
                ),
                _imageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: Colors.purple.shade600,
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.pickImage(
                        imageFileTarget, ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
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
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VIEW NOTIFICATION TAB
// ─────────────────────────────────────────────
class AllNotificationTab extends StatefulWidget {
  const AllNotificationTab({super.key});

  @override
  State<AllNotificationTab> createState() => _AllNotificationTabState();
}

class _AllNotificationTabState extends State<AllNotificationTab> {
  final NotificationController controller =
  Get.find<NotificationController>();

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  // 🆕 ADDED: search bar state (admin project jaisa hi)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    } catch (_) {
      return "N/A";
    }
  }

  // ✅ flutter_file_downloader se download — Notification Page jaisa same logic
  Future<void> _downloadAndShare({
    required String url,
    required String fileName,
    required int index,
    required String title,
    required String className,
    required String sectionName,
    required String message,
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

        _showSnack("Downloaded ✓", "File downloaded to Downloads", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));

        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Notification – $title',
          text: '📢 Title: $title\n'
              '🏫 Class: $className\n'
              '📋 Section: $sectionName\n'
              '📝 Message: $message\n'
              '🗓️ Date: $date',
        );
      },
      onDownloadError: (errorMessage) {
        if (mounted) {
          setState(() => _isDownloading[index] = false);
        }
        _showSnack("Error", "Error downloading file", Colors.red);
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

  // 🆕 ADDED: search bar widget (title / message / class / section pe filter)
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
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search by title, message, class or section...",
          hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: axisMaroonShade700),
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

        final allData = controller.notificationall.value.data ?? [];

        // 🆕 ADDED: local search filter — title/message/class/section
        final data = _searchQuery.isEmpty
            ? allData
            : allData.where((item) {
          final title = (item.tittle ?? '').toLowerCase();
          final message = (item.message ?? '').toLowerCase();
          final className = (item.className ?? '').toLowerCase();
          final sectionName = (item.sectionName ?? '').toLowerCase();
          return title.contains(_searchQuery) ||
              message.contains(_searchQuery) ||
              className.contains(_searchQuery) ||
              sectionName.contains(_searchQuery);
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
                          ? Icons.notifications_off_outlined
                          : Icons.search_off_rounded,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      allData.isEmpty
                          ? 'No notifications found'
                          : 'No matching notifications',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  final downloading = _isDownloading[index] ?? false;
                  final progress = _downloadProgress[index] ?? 0.0;

                  final titleText = item.tittle ?? 'No Title';
                  final className = item.className ?? 'N/A';
                  final sectionName = item.sectionName ?? 'N/A';
                  final messageText = item.message ?? 'No Message';
                  final date = _formatDate(item.createDate ?? '');

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
                                  Icons.campaign_rounded,
                                  color: axisMaroonShade700,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  ' $titleText',
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
                            messageText,
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
                          if (item.notificationfile?.isNotEmpty ?? false) ...[
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
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final fileUrl =
                                          "${AppUrl.base_url}${AppUrl.notificationDownloadUrl}${item.notificationfile}";
                                      final fileName =
                                      item.notificationfile!;
                                      _downloadAndShare(
                                        url: fileUrl,
                                        fileName: fileName,
                                        index: index,
                                        title: titleText,
                                        className: className,
                                        sectionName: sectionName,
                                        message: messageText,
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