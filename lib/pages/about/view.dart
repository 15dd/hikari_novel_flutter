import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/about/controller.dart';
import 'package:hikari_novel_flutter/router/app_sub_router.dart';
import 'package:hikari_novel_flutter/service/dev_mode_service.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final controller = Get.put(AboutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("about".tr), titleSpacing: 0),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(40), child: LogoPage()),
          const Divider(height: 1),
          Obx(
            () => ListTile(
              title: Text("version".tr, style: kSettingTitleTextStyle),
              subtitle: Text("${controller.version.value}(${controller.buildNumber.value})", style: kSettingSubtitleTextStyle),
              onTap: controller.onVersionTap,
            ),
          ),
          ListTile(
            title: Text("Github", style: kSettingTitleTextStyle),
            onTap: () => launchUrl(Uri.parse("https://github.com/15dd/hikari_novel_flutter")),
            trailing: const Icon(Icons.open_in_new),
          ),
          ListTile(
            title: Text("Telegram", style: kSettingTitleTextStyle),
            onTap: () => launchUrl(Uri.parse("https://t.me/+CUSABNkX5U83NGNl")),
            trailing: const Icon(Icons.open_in_new),
          ),
          Obx(
            () => Get.find<DevModeService>().enabled.value
                ? Column(
                    children: [
                      const Divider(height: 1),
                      ListTile(
                        title: Text("dev_setting".tr, style: kSettingTitleTextStyle),
                        onTap: AppSubRouter.toDevTools,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
