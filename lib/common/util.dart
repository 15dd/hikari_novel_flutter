import 'dart:ui';

import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import '../models/common/language.dart';
import '../network/api.dart';

class Util {
  static String getDateTime(String dateStr) {
    if (!LocalStorageService.instance.getIsRelativeTime()) {
      return dateStr;
    }
    final DateTime inputDate = DateTime.parse(dateStr);
    return Jiffy.parse(inputDate.toString()).fromNow();
  }

  static Locale getCurrentLocale() {
    final language = LocalStorageService.instance.getLanguage();
    if (language == Language.followSystem) {
      if (Get.deviceLocale == Locale("zh","CN")) {
        return Locale("zh","CN");
      } else if (Get.deviceLocale == Locale("zh","TW")) {
        return Locale("zh","TW");
      } else {
        return Locale("zh","CN");
      }
    }
    return switch (language) {
      Language.simplifiedChinese => Locale("zh","CN"),
      Language.traditionalChinese => Locale("zh","TW"),
      _ => Locale("zh","CN"),
    };
  }

  static Future<dynamic> isLatestVersionAvail() async {
    final response = await Api.fetchLatestRelease();
    if (response is Success) {
      final data = response.data;
      final remoteVer = data['tag_name']; // e.g. "1.2.3-beta.2+2"

      final info = await PackageInfo.fromPlatform();
      final localVer = info.version; // e.g. "1.2.0-beta.2"

      final currRemoteVer = Version.parse(remoteVer.toString().substring(0, remoteVer.toString().indexOf("+")));
      final currLocalVer = Version.parse(localVer.toString());

      return currRemoteVer > currLocalVer;
    } else {
      return response.error.toString();
    }
  }
}