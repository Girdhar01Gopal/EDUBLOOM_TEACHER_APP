import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/mapcategory.dart';
import '../models/viewphotosmodel.dart'; // ✅ PhotoData

class Mapcategoryview extends StatefulWidget {
  const Mapcategoryview({super.key});

  @override
  State<Mapcategoryview> createState() => _MapcategoryviewState();
}

class _MapcategoryviewState extends State<Mapcategoryview>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final controller = Get.put(Mapcategorycontroller());

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // ─── Date format ───
  String formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "N/A";
    final s = raw.trim();
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    }
    final parts = s.replaceAll('/', '-').split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return "${parts[2].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[0]}";
      }
      if (parts[2].length == 4) {
        return "${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[2]}";
      }
    }
    return s;
  }

  // ─── Parse date for sorting ───
  DateTime parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return DateTime(2000);
    final s = raw.trim();
    final dt = DateTime.tryParse(s);
    if (dt != null) return dt;
    final parts = s.replaceAll('/', '-').split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return DateTime.tryParse("${parts[0]}-${parts[1]}-${parts[2]}") ??
            DateTime(2000);
      }
      if (parts[2].length == 4) {
        return DateTime.tryParse("${parts[2]}-${parts[1]}-${parts[0]}") ??
            DateTime(2000);
      }
    }
    return DateTime(2000);
  }

  // ─── Base64 check ───
  bool isRawBase64(String value) {
    if (value.length % 4 != 0) return false;
    return RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(value);
  }

  // ─── Image bytes ───
  // ✅ imageBase64 pehle try karo, phir uploadImage
  Uint8List? getImageBytes(PhotoData item) {
    // Priority 1: imageBase64 field
    final b64 = item.imageBase64;
    if (b64 != null && b64.isNotEmpty) {
      try {
        if (b64.startsWith("data:image")) return base64Decode(b64.split(",").last);
        if (isRawBase64(b64)) return base64Decode(b64);
      } catch (_) {}
    }
    // Priority 2: uploadImage as base64
    final img = item.uploadImage;
    if (img != null && img.isNotEmpty) {
      try {
        if (img.startsWith("data:image")) return base64Decode(img.split(",").last);
        if (isRawBase64(img)) return base64Decode(img);
      } catch (_) {}
    }
    return null;
  }

  // ─── Image URL ───
  String? getImageUrl(PhotoData item) {
    final img = item.uploadImage;
    if (img == null || img.isEmpty) return null;
    try {
      if (img.startsWith("data:image") || isRawBase64(img)) return null;
      return img.startsWith("http")
          ? img
          : "https://playschool.edubloom.in/$img";
    } catch (_) {
      return null;
    }
  }

  // ─── Share photo ───
  Future<void> sharePhoto(PhotoData item, String? heading) async {
    try {
      final bytes = getImageBytes(item);
      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: heading ?? "Gallery Photo");
        return;
      }
      final imageUrl = getImageUrl(item);
      if (imageUrl != null) {
        await Share.share('$imageUrl\n\n${heading ?? ""}');
        return;
      }
      Get.snackbar("Error", "Unable to share image");
    } catch (_) {
      Get.snackbar("Error", "Failed to share image");
    }
  }

  // ─── Share video ───
  Future<void> shareVideo(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar("Error", "Video URL not found");
      return;
    }
    try {
      await Share.share(url, subject: 'Gallery Video');
    } catch (_) {
      Get.snackbar("Error", "Failed to share video");
    }
  }

  // ─── Zoom dialog ───
  void showZoomImage(PhotoData item, String? heading) {
    final bytes = getImageBytes(item);
    final imageUrl = getImageUrl(item);

    if (bytes == null && imageUrl == null) {
      Get.snackbar("Error", "Image not available");
      return;
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: Get.height * 0.75,
              alignment: Alignment.center,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.contain)
                    : Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      heading ?? "Image Preview",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => sharePhoto(item, heading),
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF97144D),
        elevation: 0,
        toolbarHeight: 75.h,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Gallery",
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "Photos"),
            Tab(text: "Videos"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _photosTab(),
          _videosTab(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  PHOTOS TAB
  // ══════════════════════════════════════
  Widget _photosTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.galleryCategories.isEmpty) {
        return const Center(child: Text("No uploaded photos found"));
      }

      // ─── Group by imageHeading ───
      final Map<String, List<PhotoData>> grouped = {};
      for (final item in controller.galleryCategories) {
        final key = (item.imageHeading?.trim() ?? "No Heading");
        grouped.putIfAbsent(key, () => []).add(item);
      }

      // ─── Sort: latest date first ───
      final groups = grouped.entries.toList();
      groups.sort((a, b) {
        final dateA = parseDate(a.value.first.date);
        final dateB = parseDate(b.value.first.date);
        return dateB.compareTo(dateA);
      });

      return GridView.builder(
        padding: EdgeInsets.all(12.r),
        itemCount: groups.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 10.h,
          mainAxisExtent: 240.h,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          final heading = group.key;
          final images = group.value;
          return _buildGroupedCard(heading, images);
        },
      );
    });
  }

  // ─── Card with horizontal swipeable PageView ───
  Widget _buildGroupedCard(String heading, List<PhotoData> images) {
    final pageController = PageController();
    final currentPage = ValueNotifier<int>(0);
    final firstItem = images.first;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Swipeable image area ───
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      final idx = currentPage.value;
                      showZoomImage(images[idx], heading);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        onPageChanged: (val) => currentPage.value = val,
                        itemBuilder: (context, i) {
                          return _buildImage(images[i]);
                        },
                      ),
                    ),
                  ),

                  // ─── Image count badge (top-right) ───
                  if (images.length > 1)
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: ValueListenableBuilder<int>(
                        valueListenable: currentPage,
                        builder: (_, page, __) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "${page + 1}/${images.length}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // ─── Dot indicators (bottom-center) ───
                  if (images.length > 1)
                    Positioned(
                      bottom: 6.h,
                      left: 0,
                      right: 0,
                      child: ValueListenableBuilder<int>(
                        valueListenable: currentPage,
                        builder: (_, page, __) {
                          final dotCount =
                          images.length > 5 ? 5 : images.length;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(dotCount, (i) {
                              final dotIndex = images.length > 5
                                  ? (page ~/ (images.length / 5)).clamp(0, 4)
                                  : page;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                width: i == dotIndex ? 8.w : 5.w,
                                height: i == dotIndex ? 8.h : 5.h,
                                decoration: BoxDecoration(
                                  color: i == dotIndex
                                      ? Colors.white
                                      : Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),

                  // ─── Share button (top-left) ───
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: ValueListenableBuilder<int>(
                      valueListenable: currentPage,
                      builder: (_, page, __) {
                        return GestureDetector(
                          onTap: () => sharePhoto(images[page], heading),
                          child: Container(
                            padding: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // ─── Heading ───
            Text(
              heading,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),

            SizedBox(height: 4.h),

            // ─── Date + photo count ───
            Row(
              children: [
                Text(
                  formatDate(firstItem.date),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  "${images.length} photo${images.length > 1 ? 's' : ''}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF97144D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  VIDEOS TAB
  // ══════════════════════════════════════
  Widget _videosTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.mappedCategories.isEmpty) {
        return const Center(child: Text("No videos found"));
      }

      return ListView.builder(
        padding: EdgeInsets.all(12.r),
        itemCount: controller.mappedCategories.length,
        itemBuilder: (context, index) {
          final item = controller.mappedCategories[index];
          final videoUrl = item.videoUrl ?? '';
          final className = item.className ?? '';
          final sectionName = item.sectionName ?? '';

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Thumbnail area ───
                Stack(
                  children: [
                    Container(
                      height: 155.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.videocam_rounded,
                          size: 48.r,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_fill,
                                size: 18.r, color: Colors.white),
                            SizedBox(width: 6.w),
                            Text(
                              "Play Video",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () => shareVideo(videoUrl),
                        child: Container(
                          padding: EdgeInsets.all(7.r),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.share_rounded,
                            size: 20.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // ─── Info section ───
                Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (className.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.class_rounded,
                                size: 16.r, color: const Color(0xFFAD1457)),
                            SizedBox(width: 6.w),
                            Text(
                              "Class: $className",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      if (sectionName.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.people_rounded,
                                size: 16.r, color: const Color(0xFFAD1457)),
                            SizedBox(width: 6.w),
                            Text(
                              "Section: $sectionName",
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ],
                      if (videoUrl.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.link_rounded,
                                size: 15.r, color: Colors.blue),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                videoUrl,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ─── Image builder (PhotoData use karta hai) ───
  Widget _buildImage(PhotoData item) {
    final bytes = getImageBytes(item);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.error, size: 50, color: Colors.red),
      );
    }

    final imageUrl = getImageUrl(item);
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
              child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 50, color: Colors.red),
      );
    }

    return const Center(
      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }
}