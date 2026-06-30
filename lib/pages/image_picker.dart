import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class ImagePickerScreen extends StatelessWidget {
  final String title;
  final Function(File) onImagePicked;

  ImagePickerScreen({required this.title, required this.onImagePicked});

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> _pickedFile = Rx<File?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              return _pickedFile.value == null
                  ? Text("No image selected.")
                  : Image.file(_pickedFile.value!,
                      height: 150, width: 150, fit: BoxFit.cover);
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final XFile? pickedImage =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  _pickedFile.value = File(pickedImage.path);
                  onImagePicked(_pickedFile.value!); // Return the picked image
                }
              },
              child: Text("Pick Image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_pickedFile.value != null) {
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Please select an image first');
                }
              },
              child: Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
