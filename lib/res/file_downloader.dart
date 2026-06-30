import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/utils.dart';

Future<void> DownloadFile(
    String url, String name, BuildContext context) async {
  try {
    final granted = await requestPermissions();
    if (!granted) {
      ShortMessage.snackBar(
        title: "Permission Denied",
        message: "Storage permission is required. Please allow from settings.",
        duration: 3,
      );
      await openAppSettings();
      return;
    }

    final downloadDir = Directory("/storage/emulated/0/Download");
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final safeName = name.trim().isEmpty
        ? "file_${DateTime.now().millisecondsSinceEpoch}.pdf"
        : name;

    final path = "${downloadDir.path}/$safeName";
    final file = File(path);

    final res = await http.get(Uri.parse(Uri.encodeFull(url)));

    if (res.statusCode == 200) {
      await file.writeAsBytes(res.bodyBytes);
      ShortMessage.snackBar(
        title: "Downloaded ✓",
        message: "Saved to: Downloads/$safeName",
        duration: 3,
      );
    } else {
      ShortMessage.snackBar(
        title: "Error",
        message: "Failed: ${res.statusCode}",
        duration: 3,
      );
    }
  } catch (e) {
    ShortMessage.snackBar(
      title: "Error",
      message: "Download error: $e",
      duration: 3,
    );
  }
}

Future<int> getAndroidSdkVersion() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt;
  }
  return 0;
}

Future<bool> requestPermissions() async {
  if (!Platform.isAndroid) return true;

  final sdkInt = await getAndroidSdkVersion();

  if (sdkInt >= 33) {
    return true;
  } else if (sdkInt >= 30) {
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) return true;
    final result = await Permission.manageExternalStorage.request();
    return result.isGranted;
  } else {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted;
  }
}