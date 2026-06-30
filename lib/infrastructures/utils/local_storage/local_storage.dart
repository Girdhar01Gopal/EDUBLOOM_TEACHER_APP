import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class PrefManager {
  late GetStorage _getStorage;

  initlizedStorage() {
    _getStorage = GetStorage();
  }

  Future<void> writeValue({required String key, required dynamic value}) async {
    await GetStorage().write(key, value);
  }

  Future<dynamic>? readValue({required String key}) async {
    final all = await GetStorage().read(key);
    return all;
  }

  Future<void> clearPref() async {
    await GetStorage().erase();
  }
}
