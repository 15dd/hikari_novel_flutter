import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/models/common/language.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/pages/setting/controller.dart';
import 'package:jiffy/jiffy.dart';

import '../../service/local_storage_service.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});

  final controller = Get.put(SettingController());

  final languageKey = GlobalKey();
  final nodeKey = GlobalKey();
  final themeModeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setting".tr), titleSpacing: 0),
      body: Column(
        children: [
          ListTile(
            key: languageKey,
            title: Text("language".tr, style: kSettingTitleTextStyle),
            subtitle: Obx(() {
              final str = switch (controller.language.value) {
                Language.followSystem => "follow_system".tr,
                Language.simplifiedChinese => "简体中文",
                Language.traditionalChinese => "繁體中文",
              };
              return Text(str, style: kSettingSubtitleTextStyle);
            }),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: () =>
                showMenu(
                  context: context,
                  position: languageKey.currentContext!.getMenuPosition(),
                  items: [
                    PopupMenuItem(value: Language.followSystem, child: Text("follow_system".tr)),
                    PopupMenuItem(value: Language.simplifiedChinese, child: Text("简体中文")),
                    PopupMenuItem(value: Language.traditionalChinese, child: Text("繁體中文")),
                  ],
                ).then((value) async {
                  if (value != null) controller.changeLanguage(value);
                }),
          ),
          ListTile(
            key: themeModeKey,
            title: Text("theme_mode".tr, style: kSettingTitleTextStyle),
            subtitle: Obx(() {
              final string = switch (controller.themeMode.value) {
                ThemeMode.system => "follow_system".tr,
                ThemeMode.light => "light_mode".tr,
                ThemeMode.dark => "dark_mode".tr,
              };
              return Text(string, style: kSettingSubtitleTextStyle);
            }),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: () {
              showMenu(
                context: context,
                position: themeModeKey.currentContext!.getMenuPosition(),
                items: [
                  PopupMenuItem(value: ThemeMode.system, child: Text("follow_system".tr)),
                  PopupMenuItem(value: ThemeMode.light, child: Text("light_mode".tr)),
                  PopupMenuItem(value: ThemeMode.dark, child: Text("dark_mode".tr)),
                ],
              ).then((value) {
                if (value == null) return;
                controller.changeThemeMode(value);
              });
            },
          ),
          Offstage(
            offstage: !Platform.isAndroid,
            child: Obx(
              () => SwitchListTile(
                title: Text("dynamic_color_mode".tr, style: kSettingTitleTextStyle),
                value: controller.isDynamicColor.value,
                onChanged: (value) => controller.changeIsDynamicColor(value),
              ),
            ),
          ),
          Offstage(
            offstage: controller.isDynamicColor.value && Platform.isAndroid,
            child: ListTile(
              title: Text("theme_color".tr, style: kSettingTitleTextStyle),
              trailing: Obx(() => ColorIndicator(width: 20, height: 20, borderRadius: 100, color: controller.customColor.value)),
              onTap: () => _buildColorPickerDialog(context),
            ),
          ),
          ListTile(
            key: nodeKey,
            title: Text("node".tr, style: kSettingTitleTextStyle),
            subtitle: Obx(() {
              final str = switch (controller.wenku8Node.value) {
                Wenku8Node.wwwWenku8Net => "www.wenku8.net",
                Wenku8Node.wwwWenku8Cc => "www.wenku8.cc",
              };
              return Text(str, style: kSettingSubtitleTextStyle);
            }),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: () =>
                showMenu(
                  context: context,
                  position: nodeKey.currentContext!.getMenuPosition(),
                  items: [
                    PopupMenuItem(value: Wenku8Node.wwwWenku8Net, child: Text("www.wenku8.net")),
                    PopupMenuItem(value: Wenku8Node.wwwWenku8Cc, child: Text("www.wenku8.cc")),
                  ],
                ).then((value) async {
                  if (value != null) controller.changeWenku8Node(value);
                }),
          ),
          Obx(
            () => SwitchListTile(
              title: Text("relative_time".tr, style: kSettingTitleTextStyle),
              subtitle: Text(
                "relative_time_tip".trParams({
                  "relativeTime": Jiffy.parse(DateTime.now().toString()).fromNow().toString(),
                  "normalTime": DateTime.now().toString().split('.')[0].toString(),
                }),
                style: kSettingSubtitleTextStyle,
              ),
              value: controller.isRelativeTime.value,
              onChanged: (v) => controller.changeIsRelativeTime(v),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text("auto_check_update".tr, style: kSettingTitleTextStyle),
              value: controller.isAutoCheckUpdate.value,
              onChanged: (v) => controller.changeIsAutoCheckUpdate(v),
            ),
          ),
        ],
      ),
    );
  }

  void _buildColorPickerDialog(BuildContext context) async {
    final initColor = LocalStorageService.instance.getCustomColor();
    final newColor = await showColorPickerDialog(
      context,
      initColor,
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: false,
      },
      pickerTypeLabels: <ColorPickerType, String>{ColorPickerType.primary: "theme_color".tr, ColorPickerType.wheel: "custom".tr},
      enableShadesSelection: false,
      actionButtons: ColorPickerActionButtons(dialogOkButtonLabel: "save".tr, dialogCancelButtonLabel: "cancel".tr),
      copyPasteBehavior: ColorPickerCopyPasteBehavior().copyWith(copyFormat: ColorPickerCopyFormat.hexRRGGBB),
    );
    if (newColor == initColor) return;
    controller.changeCustomColor(newColor);
  }
}
