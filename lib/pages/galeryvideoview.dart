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
                  _classDropdown(),
                  SizedBox(height: 12.h),
                  _sectionDropdown(),
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

  Widget _classDropdown() {
    return DropdownButtonFormField(
      value: controller.selectedClassId.value == 0
          ? null
          : controller.selectedClassId.value,
      decoration: const InputDecoration(
        labelText: "Select Class",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.class_),
      ),
      items: controller.classList
          .map((cls) => DropdownMenuItem(
        value: cls.classId,
        child: Text(cls.className ?? ""),
      ))
          .toList(),
      onChanged: (v) => controller.selectedClassId.value = v!,
    );
  }

  Widget _sectionDropdown() {
    return DropdownButtonFormField(
      value: controller.selectedSectionId.value == 0
          ? null
          : controller.selectedSectionId.value,
      decoration: const InputDecoration(
        labelText: "Select Section",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.segment),
      ),
      items: controller.sectionList
          .map((sec) => DropdownMenuItem(
        value: sec.sectionId,
        child: Text(sec.section ?? ""),
      ))
          .toList(),
      onChanged: (v) => controller.selectedSectionId.value = v!,
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