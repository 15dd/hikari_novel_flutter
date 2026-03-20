import 'package:get/get.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
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
      showSnackBar(message: enabled ? "dev_setting_opened".tr : "dev_setting_closed".tr, context: Get.context!);
      if (enabled) Get.toNamed(RoutePath.devTools);
    }
  }

  RxnString version = RxnString();
  RxnString buildNumber = RxnString();

  @override
  void onInit() async {
    super.onInit();
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
  }
}
