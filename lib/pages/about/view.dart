import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/about/controller.dart';
import 'package:hikari_novel_flutter/service/dev_mode_service.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final controller = Get.put(AboutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("about".tr), titleSpacing: 0),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(40), child: LogoPage()),
          Divider(height: 1),
          Obx(
            () => ListTile(
              title: Text("version".tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text("${controller.version.value}(${controller.buildNumber.value})", style: TextStyle(fontSize: 12)),
              onTap: controller.onVersionTap,
            ),
          ),
          
Obx(() {
  var enabled = false;
  try {
    enabled = Get.find<DevModeService>().enabled.value;
  } catch (_) {}
  if (!enabled) return const SizedBox.shrink();
  return ListTile(
    title: const Text("开发者工具", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    subtitle: const Text("查看与导出诊断信息", style: TextStyle(fontSize: 12)),
    onTap: () => Get.toNamed(RoutePath.devTools),
  );
}),

          ListTile(
              title: Text("Github", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () => launchUrl(Uri.parse("https://github.com/15dd/hikari_novel_flutter")),
          ),
        ],
      ),
    );
  }
}
