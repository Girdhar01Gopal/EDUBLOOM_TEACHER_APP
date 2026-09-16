import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/galaryvidevconroller.dart';

class Galeryvideoview extends GetView<Galaryvidevconroller> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(

          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp,color: Colors.white,),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: const Color(0xFF97144D), // AppBar color
          title: Text(
            "Upload Photo & Video",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: " Photo"),
              Tab(text: " Video"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _galleryTab(),
            _videoTab(),
          ],
        ),
      ),
    );
  }

  // -------------------- GALLERY TAB ----------------------
  Widget _galleryTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Gallery Details"),
            SizedBox(height: 8.h),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  _categoryMultiSelect(),
                  SizedBox(height: 12.h),
                  _datePicker(),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: controller.imageheaderController,
                    decoration: const InputDecoration(
                      labelText: "Image Header",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _sectionTitle("Images"),
            SizedBox(height: 8.h),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imagePicker(),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: SizedBox(
                width: 200.w,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: const Color(0xFFFD3C72), disabledForegroundColor: const Color(0xFFFB6E9A).withOpacity(0.38), disabledBackgroundColor: const Color(0xFFFB6E9A).withOpacity(0.12), // Gradient End
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: controller.uploadGalleryImages,
                  icon: const Icon(Icons.cloud_upload_outlined,color: Colors.white,),
                  label: const Text("Upload Images",style: TextStyle(color: Colors.white),),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  // -------------------- VIDEO TAB ----------------------
  Widget _videoTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Video Details"),
            SizedBox(height: 8.h),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _classMultiSelect(),
                  SizedBox(height: 12.h),
                  _sectionMultiSelect(),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: controller.videoUrlController,
                    decoration: const InputDecoration(
                      labelText: "Embedded Video URL",
                      hintText: "Paste YouTube embed or video URL",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: SizedBox(
                      width: 200.w,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: const Color(0xFFFD3C72), disabledForegroundColor: const Color(0xFFFB6E9A).withOpacity(0.38), disabledBackgroundColor: const Color(0xFFFB6E9A).withOpacity(0.12), // Gradient End
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: controller.uploadVideo,
                        icon: const Icon(Icons.cloud_upload_outlined,color: Colors.white,),
                        label: const Text("Upload Video",style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // -------------------- REUSABLE WIDGETS ----------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: Colors.blueGrey.shade800,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: child,
      ),
    );
  }

  Widget _categoryMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Categories",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        ...controller.galleryCategories.map((cat) {
          bool selected =
          controller.selectedCategoryIds.contains(cat.addCategoryId);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(cat.category ?? ""),
            value: selected,
            onChanged: (v) {
              if (v == true) {
                controller.selectedCategoryIds.add(cat.addCategoryId!);
              } else {
                controller.selectedCategoryIds.remove(cat.addCategoryId);
              }
            },
          );
        }).toList(),
      ],
    );
  }

  // ✅ FIXED: custom chip (theme-independent, guaranteed color change on tap)
  Widget _classMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Class (Multiple)",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 42.h,
          child: Obx(() {
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
                            ? const Color(0xFF2E7D32) // green when selected
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
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

  // ✅ FIXED: custom chip (theme-independent, guaranteed color change on tap)
  Widget _sectionMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Section (Multiple)",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 42.h,
          child: Obx(() {
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
                            ? const Color(0xFF2E7D32) // green when selected
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
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

  Widget _datePicker() {
    return TextField(
      controller: controller.dateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Select Date",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.dateController.text =
          picked.toIso8601String().split('T')[0];
        }
      },
    );
  }

  Widget _imagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Images (Multiple)",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: controller.pickImages,
              icon: const Icon(Icons.photo_library_outlined,color: Colors.white,),
              label: const Text("Pick Images",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD3C72), disabledForegroundColor: const Color(0xFFFB6E9A).withOpacity(0.38), disabledBackgroundColor: const Color(0xFFFB6E9A).withOpacity(0.12), // Gradient End
              ),
            ),
            SizedBox(width: 10.w),
            Obx(() => Text(
              "${controller.selectedImages.length} selected",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade700,
              ),
            )),
          ],
        ),
        SizedBox(height: 10.h),
        Obx(() {
          if (controller.selectedImages.isEmpty) {
            return Text(
              "No images selected.",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            );
          }
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.selectedImages
                .map(
                  (img) => ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.file(
                  img,
                  width: 70.w,
                  height: 70.w,
                  fit: BoxFit.cover,
                ),
              ),
            )
                .toList(),
          );
        }),
      ],
    );
  }
}