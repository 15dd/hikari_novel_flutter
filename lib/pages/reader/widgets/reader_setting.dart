import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/service/tts_service.dart';

import '../../../models/dual_page_mode.dart';
import '../../../models/reader_direction.dart';
import '../controller.dart';

class ReaderSettingPage extends StatelessWidget {
  ReaderSettingPage({super.key});

  final ReaderController controller = Get.find();

  final readerDirectionKey = GlobalKey(); //负责获取对应组件的context，类似this.context
  final dualPageModeKey = GlobalKey();
  final textStyleKey = GlobalKey();
  final textColorKey = GlobalKey();
  final bgColorKey = GlobalKey();
  final bgImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("setting".tr),
          titleSpacing: 0,
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.settings_outlined), text: "basic".tr),
              Tab(icon: const Icon(Icons.palette_outlined), text: "theme".tr),
              const Tab(icon: Icon(Icons.menu_book_outlined), text: '听书'),
              Tab(icon: const Icon(Icons.padding), text: "margin".tr),
            ],
          ),
        ),
        body: TabBarView(children: [_buildBasic(context), _buildTheme(context), _buildListen(context), _buildPadding()]),
      ),
    );
  }

  Widget _buildBasic(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Row(
            children: [
              Text("font_size".tr, style: kSettingTitleTextStyle),
              const Spacer(),
              Obx(() => Text(controller.readerSettingsState.value.fontSize.toStringAsFixed(0), style: kSettingSubtitleTextStyle)),
            ],
          ),
          subtitle: Obx(
            () => Slider(
              min: 7,
              max: 48,
              divisions: 41,
              value: controller.readerSettingsState.value.fontSize,
              onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(fontSize: value),
              onChangeEnd: (value) => controller.changeFontSize(value),
            ),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Text("line_spacing".tr, style: kSettingTitleTextStyle),
              const Spacer(),
              Obx(() => Text(controller.readerSettingsState.value.lineSpacing.toStringAsFixed(1), style: kSettingSubtitleTextStyle)),
            ],
          ),
          subtitle: Obx(
            () => Slider(
              min: 0.1,
              max: 3.0,
              divisions: 29,
              value: controller.readerSettingsState.value.lineSpacing,
              onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(lineSpacing: value),
              onChangeEnd: (value) => controller.changeLineSpacing(value),
            ),
          ),
        ),
        ListTile(
          key: readerDirectionKey,
          title: Text("reading_direction".tr, style: kSettingTitleTextStyle),
          subtitle: Obx(
            () => Text(switch (controller.readerSettingsState.value.direction) {
              ReaderDirection.leftToRight => "left_to_right".tr,
              ReaderDirection.rightToLeft => "right_to_left".tr,
              ReaderDirection.upToDown => "scroll".tr,
            }, style: kSettingSubtitleTextStyle),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down),
          onTap: () {
            showMenu(
              context: context,
              position: readerDirectionKey.currentContext!.getMenuPosition(),
              items: [
                PopupMenuItem(value: ReaderDirection.upToDown, child: Text("scroll".tr)),
                PopupMenuItem(value: ReaderDirection.leftToRight, child: Text("left_to_right".tr)),
                PopupMenuItem(value: ReaderDirection.rightToLeft, child: Text("right_to_left".tr)),
              ],
            ).then((value) {
              if (value != null) controller.changeReaderDirection(value);
            });
          },
        ),
        Offstage(
          offstage: controller.readerSettingsState.value.direction == ReaderDirection.upToDown,
          child: Obx(
            () => SwitchListTile(
              title: Text("page_turning_animation".tr, style: kSettingTitleTextStyle),
              value: controller.readerSettingsState.value.pageTurningAnimation,
              onChanged: (enabled) => controller.changeReaderPageTurningAnimation(enabled),
            ),
          ),
        ),
        Obx(
          () => SwitchListTile(
            title: Text("screen_stays_on".tr, style: kSettingTitleTextStyle),
            value: controller.readerSettingsState.value.wakeLock,
            onChanged: (enabled) => controller.changeReaderWakeLock(enabled),
          ),
        ),
        Offstage(
          offstage: !(Platform.isAndroid || Platform.isIOS),
          child: Obx(
            () => SwitchListTile(
              title: Text("immersive_mode".tr, style: kSettingTitleTextStyle),
              value: controller.readerSettingsState.value.immersionMode,
              onChanged: (enabled) => controller.changeImmersionMode(enabled),
            ),
          ),
        ),
        Obx(
          () => SwitchListTile(
            title: Text("show_status_bar".tr, style: kSettingTitleTextStyle),
            value: controller.readerSettingsState.value.showStatusBar,
            onChanged: (enabled) => controller.changeShowStatusBar(enabled),
          ),
        ),
        Obx(
          () => Offstage(
            offstage: controller.readerSettingsState.value.direction == ReaderDirection.upToDown,
            child: ListTile(
              key: dualPageModeKey,
              title: Text("dual_page".tr, style: kSettingTitleTextStyle),
              subtitle: Obx(() => Text(controller.readerSettingsState.value.dualPageMode.name.tr, style: kSettingSubtitleTextStyle)),
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () {
                showMenu(
                  context: context,
                  position: dualPageModeKey.currentContext!.getMenuPosition(),
                  items: [
                    PopupMenuItem(value: DualPageMode.auto, child: Text("auto".tr)),
                    PopupMenuItem(value: DualPageMode.enabled, child: Text("enable".tr)),
                    PopupMenuItem(value: DualPageMode.disabled, child: Text("disable".tr)),
                  ],
                ).then((value) {
                  if (value != null) controller.changeDualPageMode(value);
                });
              },
            ),
          ),
        ),
        Obx(() {
          final dualPageMode = switch (controller.readerSettingsState.value.dualPageMode) {
            DualPageMode.auto => Get.context!.isLargeScreen(),
            DualPageMode.enabled => true,
            DualPageMode.disabled => false,
          };
          return Offstage(
            offstage: !dualPageMode || controller.readerSettingsState.value.direction == ReaderDirection.upToDown,
            child: ListTile(
              title: Row(
                children: [
                  Text("dual_page_spacing".tr, style: kSettingTitleTextStyle),
                  const Spacer(),
                  Obx(() => Text(controller.readerSettingsState.value.dualPageSpacing.toStringAsFixed(0), style: kSettingSubtitleTextStyle)),
                ],
              ),
              subtitle: Obx(
                () => Slider(
                  min: 0,
                  max: 60,
                  divisions: 120,
                  value: controller.readerSettingsState.value.dualPageSpacing,
                  onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(dualPageSpacing: value),
                  onChangeEnd: (value) => controller.changeDualPageSpacing(value),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTheme(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          key: textStyleKey,
          title: Text("font".tr, style: kSettingTitleTextStyle),
          subtitle: Obx(
            () => Text(
              controller.isFontFileAvailable.value ? controller.readerSettingsState.value.textFamily.toString() : "system_font".tr,
              style: kSettingSubtitleTextStyle,
            ),
          ),
          trailing: Icon(Icons.keyboard_arrow_down),
          onTap: () {
            showMenu(
              context: context,
              position: textStyleKey.currentContext!.getMenuPosition(),
              items: [
                PopupMenuItem(value: 0, child: Text("system_font".tr)),
                PopupMenuItem(value: 1, child: Text("custom_font".tr)),
              ],
            ).then((value) async {
              if (value == 0) {
                await controller.deleteFontDir();
                controller.changeReaderTextStyleFilePath(null);
                controller.changeReaderTextFamily(null);
                controller.checkFontFile(false);
                ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("set_system_font_successfully".tr)));
              } else if (value == 1) {
                final result = await controller.pickTextStyleFile();
                switch (result) {
                  case null:
                    return;
                  case true:
                    {
                      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("set_font_successfully".tr)));
                      controller.checkFontFile(false);
                    }
                  case false:
                    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("set_font_failed".tr)));
                }
              }
            });
          },
        ),
        ListTile(
          key: textColorKey,
          title: Text("font_color".tr, style: kSettingTitleTextStyle),
          trailing: Obx(
            () => controller.currentTextColor.value == null
                ? const Icon(Icons.keyboard_arrow_down)
                : ColorIndicator(width: 20, height: 20, borderRadius: 100, color: controller.currentTextColor.value!),
          ),
          onTap: () {
            showMenu(
              context: context,
              position: textColorKey.currentContext!.getMenuPosition(),
              items: [
                PopupMenuItem(value: 0, child: Text("change_font_color".tr)),
                PopupMenuItem(value: 1, child: Text("reset_font_color".tr)),
              ],
            ).then((value) {
              if (value == 0) {
                _buildColorPickerDialog(Get.context!, true);
              } else if (value == 1) {
                Get.context!.isDarkMode ? controller.changeReaderNightTextColor(null) : controller.changeReaderDayTextColor(null);
                ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("reset_font_color_successfully".tr)));
              }
            });
          },
        ),
        ListTile(
          key: bgColorKey,
          title: Text("background_color".tr, style: kSettingTitleTextStyle),
          trailing: Obx(
            () => controller.currentBgColor.value == null
                ? Icon(Icons.keyboard_arrow_down)
                : ColorIndicator(width: 20, height: 20, borderRadius: 100, color: controller.currentBgColor.value!),
          ),
          onTap: () {
            showMenu(
              context: context,
              position: bgColorKey.currentContext!.getMenuPosition(),
              items: [
                PopupMenuItem(value: 0, child: Text("change_background_color".tr)),
                PopupMenuItem(value: 1, child: Text("reset_background_color".tr)),
              ],
            ).then((value) {
              if (value == 0) {
                _buildColorPickerDialog(Get.context!, false);
              } else if (value == 1) {
                Get.context!.isDarkMode ? controller.changeReaderNightBgColor(null) : controller.changeReaderDayBgColor(null);
                ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("reset_background_color_successfully".tr)));
              }
            });
          },
        ),
        ListTile(
          key: bgImageKey,
          title: Text("background_image".tr, style: kSettingTitleTextStyle),
          trailing: Icon(Icons.keyboard_arrow_down),
          onTap: () {
            showMenu(
              context: context,
              position: bgImageKey.currentContext!.getMenuPosition(),
              items: [
                PopupMenuItem(value: 0, child: Text("change_background_image".tr)),
                PopupMenuItem(value: 1, child: Text("reset_background_image".tr)),
              ],
            ).then((value) async {
              if (value == 0) {
                final result = await controller.pickBgImageFile(Get.context!.isDarkMode);
                switch (result) {
                  case null:
                    return;
                  case true:
                    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("set_background_successfully".tr)));
                  case false:
                    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("set_background_failed".tr)));
                }
              } else if (value == 1) {
                Get.context!.isDarkMode ? controller.changeReaderNightBgImage(null) : controller.changeReaderDayBgImage(null);
                ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("reset_background_image_successfully".tr)));
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildListen(BuildContext context) {
    final tts = TtsService.instance;
    return ListView(
      children: [
        Obx(
          () => SwitchListTile(
            title: Text('启用听书', style: kSettingTitleTextStyle),
            value: tts.enabled.value,
            onChanged: (v) => tts.setEnabled(v),
          ),
        ),
        ListTile(
          title: Text('打开系统TTS设置', style: kSettingTitleTextStyle),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => tts.openAndroidTtsSettings(),
        ),
        Obx(
          () => ListTile(
            title: Text('TTS引擎', style: kSettingTitleTextStyle),
            subtitle: Text(
              tts.engine.value == null ? (Platform.isAndroid ? '自动(系统默认)' : '当前系统不支持切换引擎') : tts.displayEngineName(tts.engine.value!),
              style: kSettingSubtitleTextStyle,
            ),
            enabled: tts.enabled.value && Platform.isAndroid,
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: (!tts.enabled.value || !Platform.isAndroid)
                ? null
                : () async {
                    await tts.refreshEngines();
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return Obx(
                          () => ListView(
                            children: [
                              ListTile(
                                title: Text('自动(系统默认)'),
                                onTap: () {
                                  tts.applyEngine(null);
                                  Navigator.pop(ctx);
                                },
                              ),
                              ...tts.engines.map(
                                (e) => ListTile(
                                  title: Text(tts.displayEngineName(e)),
                                  onTap: () async {
                                    await tts.applyEngine(e);
                                    await tts.refreshVoices();
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
          ),
        ),
        Obx(
          () => ListTile(
            title: Text('音色', style: kSettingTitleTextStyle),
            subtitle: Text(
              tts.voice.value == null
                  ? '自动'
                  : '${tts.voice.value!['name']} (${tts.voice.value!['locale']})',
              style: kSettingSubtitleTextStyle,
            ),
            enabled: tts.enabled.value,
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: !tts.enabled.value
                ? null
                : () async {
                    await tts.refreshVoices();
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return Obx(
                          () => ListView(
                            children: [
                              ListTile(
                                title: Text('自动'),
                                onTap: () {
                                  tts.applyVoice(null);
                                  Navigator.pop(ctx);
                                },
                              ),
                              ...tts.voices.map(
                                (v) => ListTile(
                                  title: Text(v['name'] ?? ''),
                                  subtitle: Text(v['locale'] ?? ''),
                                  onTap: () async {
                                    await tts.applyVoice(v);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
          ),
        ),
        const Divider(height: 1),
        Obx(
          () => ListTile(
            title: Row(
              children: [
                Text('语速', style: kSettingTitleTextStyle),
                const Spacer(),
                Text(tts.rate.value.toStringAsFixed(2), style: kSettingSubtitleTextStyle),
              ],
            ),
            subtitle: Slider(
              min: 0.1,
              max: 1.0,
              divisions: 18,
              value: tts.rate.value,
              onChanged: tts.enabled.value ? (v) => tts.setRate(v) : null,
            ),
          ),
        ),
        Obx(
          () => ListTile(
            title: Row(
              children: [
                Text('音调', style: kSettingTitleTextStyle),
                const Spacer(),
                Text(tts.pitch.value.toStringAsFixed(2), style: kSettingSubtitleTextStyle),
              ],
            ),
            subtitle: Slider(
              min: 0.5,
              max: 2.0,
              divisions: 15,
              value: tts.pitch.value,
              onChanged: tts.enabled.value ? (v) => tts.setPitch(v) : null,
            ),
          ),
        ),
        Obx(
          () => ListTile(
            title: Row(
              children: [
                Text('音量', style: kSettingTitleTextStyle),
                const Spacer(),
                Text(tts.volume.value.toStringAsFixed(2), style: kSettingSubtitleTextStyle),
              ],
            ),
            subtitle: Slider(
              min: 0.0,
              max: 1.0,
              divisions: 20,
              value: tts.volume.value,
              onChanged: tts.enabled.value ? (v) => tts.setVolume(v) : null,
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('刷新设置', style: kSettingTitleTextStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '修改语速/音调/音量后，需点击“刷新设置”才会立即生效（部分引擎播放中无法实时更新）。',
            style: kSettingSubtitleTextStyle,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: tts.enabled.value ? () => tts.refreshSettings(restartIfPlaying: true) : null,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新设置'),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
Widget _buildPadding() {
    return ListView(
      children: [
        ListTile(
          title: Row(
            children: [
              Text("left_margin".tr, style: kSettingTitleTextStyle),
              const Spacer(),
              Obx(() => Text(controller.readerSettingsState.value.leftMargin.toStringAsFixed(0), style: kSettingSubtitleTextStyle)),
            ],
          ),
          subtitle: Obx(
            () => Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: controller.readerSettingsState.value.leftMargin,
              onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(leftMargin: value),
              onChangeEnd: (value) => controller.changeLeftMargin(value),
            ),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Text("top_margin".tr, style: kSettingTitleTextStyle),
              const Spacer(),
              Obx(() => Text(controller.readerSettingsState.value.topMargin.toStringAsFixed(0), style: kSettingSubtitleTextStyle)),
            ],
          ),
          subtitle: Obx(
            () => Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: controller.readerSettingsState.value.topMargin,
              onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(topMargin: value),
              onChangeEnd: (value) => controller.changeTopMargin(value),
            ),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Text("right_margin".tr, style: kSettingTitleTextStyle),
              const Spacer(),
              Obx(() => Text(controller.readerSettingsState.value.rightMargin.toStringAsFixed(0), style: kSettingSubtitleTextStyle)),
            ],
          ),
          subtitle: Obx(
            () => Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: controller.readerSettingsState.value.rightMargin,
              onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(rightMargin: value),
              onChangeEnd: (value) => controller.changeRightMargin(value),
            ),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Text("bottom_margin".tr, style: kSettingTitleTextStyle),
              const Spacer(),
              Obx(() => Text(controller.readerSettingsState.value.bottomMargin.toStringAsFixed(0), style: kSettingSubtitleTextStyle)),
            ],
          ),
          subtitle: Obx(
            () => Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: controller.readerSettingsState.value.bottomMargin,
              onChanged: (value) => controller.readerSettingsState.value = controller.readerSettingsState.value.copyWith(bottomMargin: value),
              onChangeEnd: (value) => controller.changeBottomMargin(value),
            ),
          ),
        ),
      ],
    );
  }

  /// [isChangeText] `true` 表示修改字体颜色，`false` 表示修改背景颜色`
  void _buildColorPickerDialog(BuildContext context, bool isChangeText) async {
    final initColor = isChangeText
        ? controller.currentTextColor.value ?? Theme.of(context).colorScheme.onSurface
        : controller.currentBgColor.value ?? Theme.of(context).colorScheme.surface;
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
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      enableShadesSelection: false,
      actionButtons: ColorPickerActionButtons(dialogOkButtonLabel: "save".tr, dialogCancelButtonLabel: "cancel".tr),
      copyPasteBehavior: ColorPickerCopyPasteBehavior().copyWith(copyFormat: ColorPickerCopyFormat.hexRRGGBB),
    );
    if (newColor == initColor) return;
    if (Get.context!.isDarkMode) {
      isChangeText ? controller.changeReaderNightTextColor(newColor) : controller.changeReaderNightBgColor(newColor);
    } else {
      isChangeText ? controller.changeReaderDayTextColor(newColor) : controller.changeReaderDayBgColor(newColor);
    }

    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("color_set_successfully".tr)));
  }
}