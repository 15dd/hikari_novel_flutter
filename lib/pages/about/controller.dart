import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutController extends GetxController {
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
