import 'package:get/get.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';

class DevModeService extends GetxService {
  static DevModeService get instance => Get.find<DevModeService>();

  final RxBool enabled = false.obs;

  Future<DevModeService> init() async {
    enabled.value = LocalStorageService.instance.getDevModeEnabled();
    return this;
  }

  Future<void> enable() async {
    enabled.value = true;
    await LocalStorageService.instance.setDevModeEnabled(true);
  }

  Future<void> disable() async {
    enabled.value = false;
    await LocalStorageService.instance.setDevModeEnabled(false);
  }

  Future<bool> toggle() async {
    if (enabled.value) {
      await disable();
      return false;
    } else {
      await enable();
      return true;
    }
  }
}
