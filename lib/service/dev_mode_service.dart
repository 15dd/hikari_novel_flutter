import 'package:get/get.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';

class DevModeService extends GetxService {
  static DevModeService get instance => Get.find<DevModeService>();

  final RxBool enabled = false.obs;

  void init() => enabled.value = LocalStorageService.instance.getDevModeEnabled();

  void enable() {
    enabled.value = true;
    LocalStorageService.instance.setDevModeEnabled(true);
  }

  void disable()  {
    enabled.value = false;
    LocalStorageService.instance.setDevModeEnabled(false);
  }

  bool toggle() {
    if (enabled.value) {
      disable();
      return false;
    } else {
      enable();
      return true;
    }
  }
}
