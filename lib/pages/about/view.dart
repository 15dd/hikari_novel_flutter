import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/pages/about/controller.dart';
import 'package:hikari_novel_flutter/widgets/custom_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/util.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final controller = Get.put(AboutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("about".tr), titleSpacing: 0),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: Image.asset("assets/images/logo_transparent.png", width: 200, height: 200)),
          ),
          const Divider(height: 1),
          Obx(
            () => NormalTile(
              title: "version".tr,
              subtitle: "${controller.version.value}(${controller.buildNumber.value})",
              leading: const Icon(Icons.commit)
            ),
          ),
          NormalTile(title: "check_update".tr, leading: const Icon(Icons.update), onTap: () => Util.checkUpdate(true)),
          NormalTile(
            title: "open_source_license".tr,
            leading: const Icon(Icons.assignment_outlined),
            onTap: () => showLicensePage(
              context: context,
              applicationName: kAppName,
              applicationIcon: Center(child: Image.asset("assets/images/logo_transparent.png", width: 200, height: 200)),
            ),
          ),
          NormalTile(
            title: "Github",
            leading: const Icon(Icons.code),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(Uri.parse("https://github.com/15dd/hikari_novel_flutter")),
          ),
          NormalTile(
            title: "Telegram",
            leading: const Icon(Icons.group),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(Uri.parse("https://t.me/+CUSABNkX5U83NGNl")),
          )
        ],
      ),
    );
  }
}
