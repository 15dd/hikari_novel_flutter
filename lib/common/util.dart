import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';
import 'package:jiffy/jiffy.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
      if (Get.deviceLocale == Locale("zh", "CN")) {
        return Locale("zh", "CN");
      } else if (Get.deviceLocale == Locale("zh", "TW")) {
        return Locale("zh", "TW");
      } else {
        return Locale("zh", "CN");
      }
    }
    return switch (language) {
      Language.simplifiedChinese => Locale("zh", "CN"),
      Language.traditionalChinese => Locale("zh", "TW"),
      _ => Locale("zh", "CN"),
    };
  }

  static Future<void> checkUpdate(bool mustNotification) async {
    final response = await Api.fetchLatestRelease();
    if (response is Success) {
      final data = response.data;
      final remoteVer = data["tag_name"]; // e.g. "1.2.3-beta.2+2"

      final info = await PackageInfo.fromPlatform();
      final localVer = info.version; // e.g. "1.2.0-beta.2"

      bool hasNewVersion = localVer.toString() != remoteVer.toString().substring(0, remoteVer.toString().indexOf("+"));

      //不需要通知且没有新版本，直接返回
      if (!mustNotification && !hasNewVersion) return;

      Get.dialog(
        AlertDialog(
          title: Text("check_update".tr),
          content: hasNewVersion
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("new_version_available".tr, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      MarkdownBlock(data: data["body"]),
                    ],
                  ),
                )
              : Text("no_new_version_available".tr),
          actions: [TextButton(onPressed: Get.back, child: Text("confirm".tr))],
        ),
      );
    } else {
      if (mustNotification) {
        Get.dialog(
          AlertDialog(
            title: Text("check_update".tr),
            content: Text(response.error.toString()),
            actions: [TextButton(onPressed: Get.back, child: Text("confirm".tr))],
          ),
        );
      }
    }
  }
}
