import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hikari_novel_flutter/service/dev_mode_service.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/common/app_toast.dart';

class AboutController extends GetxController {
  int _versionTapCount = 0;

  void onVersionTap() async {
    _versionTapCount++;
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      final enabled = await DevModeService.instance.toggle();
      final ctx = Get.context;
      if (ctx != null) {
        AppToast.show(
          ctx,
          text: enabled ? '您已打开开发者模式。' : '您已关闭开发者模式。',
        );
      }
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