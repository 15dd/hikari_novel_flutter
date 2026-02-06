import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hikari_novel_flutter/service/dev_mode_service.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';

class AboutController extends GetxController {
  int _versionTapCount = 0;

  void onVersionTap() {
    _versionTapCount++;
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      final enabled = DevModeService.instance.toggle();
      //TODO 1）风格不统一，应去除；2）翻译
      Get.snackbar(
        '开发者模式',
        enabled ? '您已打开开发者模式。' : '您已关闭开发者模式。',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      if (enabled) {
        Get.toNamed(RoutePath.devTools);
      }
    }
  }

  RxnString version = RxnString();
  RxnString buildNumber= RxnString();

  @override
  void onInit() async {
    super.onInit();
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
  }
}