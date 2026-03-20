import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/log.dart';
import 'package:hikari_novel_flutter/models/reader_direction.dart';
import 'package:hikari_novel_flutter/pages/reader/controller.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/custom_header.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/custom_slider.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/horizontal_read_page.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/reader_background.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/vertical_read_page.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
import 'package:intl/intl.dart';
import 'package:hikari_novel_flutter/service/tts_service.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/tts_floating_controller.dart';

import '../../common/constants.dart';
import '../../models/page_state.dart';
import '../../router/route_path.dart';

class ReaderPage extends StatelessWidget {
  ReaderPage({super.key});

  final controller = Get.put(ReaderController());

  final GlobalKey<VerticalReadPageState> _verticalReadPageKey = GlobalKey();

  EdgeInsets get padding => EdgeInsets.fromLTRB(
    controller.readerSettingsState.value.leftMargin,
    controller.readerSettingsState.value.topMargin,
    controller.readerSettingsState.value.rightMargin,
    controller.readerSettingsState.value.showStatusBar
        ? controller.readerSettingsState.value.bottomMargin + kStatusBarPadding
        : controller.readerSettingsState.value.bottomMargin,
  );

  TextStyle get textStyle => TextStyle(
    fontFamily: controller.readerSettingsState.value.textFamily,
    height: controller.readerSettingsState.value.lineSpacing,
    fontSize: controller.readerSettingsState.value.fontSize,
    color: controller.currentTextColor.value ?? Theme.of(Get.context!).colorScheme.onSurface,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => controller.pageState.value == PageState.success
                ? ReaderBackground(
                    child: Obx(
                      () => Padding(
                        padding: EdgeInsets.only(
                          bottom: controller.readerSettingsState.value.showStatusBar ? kStatusBarPadding + MediaQuery.of(context).padding.bottom : 0,
                        ),
                        child: _buildReadPage(context),
                      ),
                    ),
                  )
                : Container(),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: const LoadingPage())),
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.error,
              child: ErrorMessage(msg: controller.errorMsg, action: controller.getContent),
            ),
          ),
          _buildBottomStatusBar(context),
          const TtsFloatingController(),
          Obx(() {
            //顶栏
            double statusBarHeight = MediaQuery.of(context).padding.top;
            return AnimatedPositioned(
              top: controller.showBar.value ? 0 : -(kToolbarHeight + statusBarHeight),
              left: 0,
              right: 0,
              duration: Duration(milliseconds: 100),
              child: AppBar(backgroundColor: Theme.of(context).colorScheme.secondaryContainer, title: Text(controller.chapterTitle.value), titleSpacing: 0),
            );
          }),
          Obx(() {
            //底栏
            double navigationBarHeight = MediaQuery.of(context).padding.bottom;
            int bottomBarHeight = 100;
            return AnimatedPositioned(
              left: 0,
              right: 0,
              bottom: controller.showBar.value ? 0 : -(navigationBarHeight + bottomBarHeight),
              duration: const Duration(milliseconds: 100),
              child: Container(
                height: navigationBarHeight + bottomBarHeight,
                color: Theme.of(context).colorScheme.secondaryContainer,
                alignment: Alignment.center,
                child: Obx(
                  () => Column(
                    children: [
                      SizedBox(width: double.infinity, child: _buildProgressBar(context)),
                      Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                if (controller.readerSettingsState.value.direction == ReaderDirection.rightToLeft) {
                                  controller.nextChapter();
                                } else {
                                  controller.prevChapter();
                                }
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                          Expanded(
                            child: IconButton(onPressed: () => _showCatalogue(context), icon: const Icon(Icons.list_alt)),
                          ),
                          Expanded(
                            child: IconButton(onPressed: () => Get.toNamed(RoutePath.readerSetting), icon: const Icon(Icons.settings_outlined)),
                          ),
                          TtsService.instance.enabled.value
                              ? Expanded(
                                  child: IconButton(
                                    tooltip: "listen_to_books".tr,
                                    onPressed: () async {
                                      final tts = TtsService.instance;
                                      final text = controller.text.value;
                                      final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
                                      if (cleaned.isEmpty) {
                                        showSnackBar(message: "chapter_content_loading_tip".tr, context: context);
                                        return;
                                      }

                                      if (tts.isPlaying.value) {
                                        await tts.stop();
                                        return;
                                      }
                                      if (tts.isPaused.value && tts.isSessionActive.value) {
                                        await tts.resumeSession();
                                        return;
                                      }

                                      await tts.startChapter(cleaned);
                                    },
                                    icon: Obx(() {
                                      final tts = TtsService.instance;
                                      if (tts.isPlaying.value) {
                                        return const Icon(Icons.stop_circle_outlined);
                                      }
                                      return const Icon(Icons.play_circle_outline);
                                    }),
                                  ),
                                )
                              : Container(),
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                if (controller.readerSettingsState.value.direction == ReaderDirection.rightToLeft) {
                                  controller.prevChapter();
                                } else {
                                  controller.nextChapter();
                                }
                              },
                              icon: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReadPage(BuildContext context) {
    return Obx(() {
      if (controller.pageState.value == PageState.success) {
        return controller.readerSettingsState.value.direction == ReaderDirection.upToDown ? _buildVertical(context) : _buildHorizontal(context);
      } else {
        return Container();
      }
    });
  }

  Widget _buildVertical(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => controller.showBar.value = !controller.showBar.value,
      child: SizedBox(
        height: double.infinity,
        child: EasyRefresh(
          header: MaterialHeader2(
            triggerOffset: 80,
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.arrow_circle_up, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          footer: MaterialFooter2(
            triggerOffset: 80,
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.arrow_circle_down, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          refreshOnStart: false,
          onRefresh: controller.prevChapter,
          onLoad: controller.nextChapter,
          child: VerticalReadPage(
            key: _verticalReadPageKey,
            controller.text.value,
            controller.images,
            initialOffset: controller.getInitLocation(),
            padding: padding,
            style: textStyle,
            paraSpacing: controller.readerSettingsState.value.readerParaSpacing,
            paraIndent: controller.readerSettingsState.value.readerParaIndent,
            onScroll: (position, max) {
              if (max == 0 && position == 0) {
                controller.currentLocation.value = 0;
                controller.verticalProgress.value = 100;
                controller.setReadHistory();
              } else if (max > 0) {
                controller.currentLocation.value = position.toInt();
                controller.verticalProgress.value = ((position.toInt() / max.toInt()) * 100).clamp(0, 100).toInt();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final usePaperCurl = controller.readerSettingsState.value.pageTurningAnimation && !controller.isDualPage;
    final horizontalReader = HorizontalReadPage(
      controller.text.value,
      controller.images,
      initIndex: controller.getInitLocation(),
      padding: padding,
      style: textStyle,
      reverse: controller.readerSettingsState.value.direction == ReaderDirection.rightToLeft,
      isDualPage: controller.isDualPage,
      dualPageSpacing: controller.readerSettingsState.value.dualPageSpacing,
      controller: controller.pageController,
      pageTurningAnimation: controller.readerSettingsState.value.pageTurningAnimation,
      paperCurlController: controller.paperCurlController,
      onCenterTap: () => controller.showBar.value = !controller.showBar.value,
      onReachStart: controller.prevChapter,
      onReachEnd: controller.nextChapter,
      onPageChanged: (index, max) {
        controller.currentIndex.value = index;
        controller.maxPage.value = max;
        if (max == 1 && index == 0) {
          //仅一页的情况下
          controller.horizontalProgress.value = 100;
          controller.setReadHistory(); //立即更新历史阅读记录
        } else if (max > 0) {
          controller.horizontalProgress.value = int.parse(((index + 1) / max * 100.0).toStringAsFixed(0)).clamp(0, 100);
          //由controller的debounce监听currentIndex变化，判断是否更新历史阅读记录
        }
      },
      onViewImage: (index) => Get.toNamed(RoutePath.photo, arguments: {"gallery_mode": true, "list": controller.images, "index": index}),
    );

    if (usePaperCurl) {
      return horizontalReader;
    }

    return EasyRefresh(
      header: MaterialHeader2(
        triggerOffset: 80,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(12),
          child: Icon(Icons.arrow_circle_left_outlined, color: Theme.of(context).colorScheme.primary),
        ),
      ),
      footer: MaterialFooter2(
        triggerOffset: 80,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(12),
          child: Icon(Icons.arrow_circle_right_outlined, color: Theme.of(context).colorScheme.primary),
        ),
      ),
      refreshOnStart: false,
      onRefresh: controller.prevChapter,
      onLoad: controller.nextChapter,
      child: horizontalReader,
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      if (controller.pageState.value != PageState.success) return SizedBox(height: 48, child: Container());
      if (controller.readerSettingsState.value.direction == ReaderDirection.upToDown) {
        int value = controller.verticalProgress.value;

        return SizedBox(
          height: 48,
          child: Row(
            children: [
              SizedBox(width: 60, child: Center(child: Text("$value%"))),
              Expanded(
                child: Slider(
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Theme.of(context).colorScheme.surface,
                  value: value.toDouble(),
                  max: 100.0,
                  onChanged: (e) {
                    _verticalReadPageKey.currentState!.jumpToProgress(e);
                  },
                  divisions: 99,
                ),
              ),
              SizedBox(width: 60, child: Center(child: Text("100%"))),
            ],
          ),
        );
      } else {
        int value = controller.currentIndex.value + 1;
        int max = controller.maxPage.value;

        if (value > max || max == 1) {
          return SizedBox(height: 48, child: Center(child: Text("only_one_page".tr)));
        }
        return SizedBox(
          height: 48,
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Center(
                  child: controller.readerSettingsState.value.direction == ReaderDirection.leftToRight ? Text(value.toString()) : Text(max.toString()),
                ),
              ),
              Expanded(
                child: CustomSlider(
                  min: 1,
                  max: max.toDouble(),
                  value: value.toDouble(),
                  divisions: max - 1,
                  onChanged: (v) => controller.jumpToPage((v - 1).toInt()),
                  focusNode: null,
                  reversed: controller.readerSettingsState.value.direction != ReaderDirection.leftToRight,
                ),
              ),
              SizedBox(
                width: 60,
                child: Center(
                  child: controller.readerSettingsState.value.direction == ReaderDirection.leftToRight ? Text(max.toString()) : Text(value.toString()),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  void _showCatalogue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: BottomSheet(
          onClosing: () {},
          builder: (_) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.catalogue.length,
                  itemBuilder: (context, volumeIndex) {
                    final volume = controller.catalogue[volumeIndex];

                    return ExpansionTile(
                      shape: const Border(),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(volume.title, style: const TextStyle(fontSize: 15)),
                      ),
                      children: volume.chapters.asMap().entries.map((entry) {
                        final chapterIndex = entry.key;
                        final chapter = entry.value;

                        return ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              volumeIndex == controller.currentVolumeIndex && chapterIndex == controller.currentChapterIndex
                                  ? Row(
                                      children: [
                                        SizedBox(height: 22, child: Icon(Icons.arrow_circle_right, color: Theme.of(context).colorScheme.primary)),
                                        const SizedBox(width: 10),
                                      ],
                                    )
                                  : Container(),
                              Text(
                                chapter.title,
                                style: volumeIndex == controller.currentVolumeIndex && chapterIndex == controller.currentChapterIndex
                                    ? TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
                                    : const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.only(left: 50.0, right: 10.0),
                          onTap: () {
                            controller.currentVolumeIndex = volumeIndex;
                            controller.currentChapterIndex = chapterIndex;
                            controller.getContent();
                            Get.back();
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomStatusBar(BuildContext context) {
    return Positioned(
      right: 8,
      left: 8,
      bottom: 4,
      child: Obx(
        () => Offstage(
          offstage: !(controller.readerSettingsState.value.showStatusBar && controller.pageState.value == PageState.success),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: controller.clockStream(),
                  builder: (_, snapshot) {
                    final now = snapshot.data ?? DateTime.now();
                    final timeString = DateFormat('HH:mm').format(now);
                    return Text(timeString, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface));
                  },
                ),
                const SizedBox(width: 8),
                _buildBattery(context, controller.batteryLevel.value),
                Text("${controller.batteryLevel.value}%", style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                const Spacer(),
                controller.readerSettingsState.value.direction == ReaderDirection.upToDown
                    ? Text("${controller.verticalProgress.value} %", style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface))
                    : Text(
                        "${controller.currentIndex.value + 1} / ${controller.maxPage.value}",
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBattery(BuildContext context, int value) {
    if (value >= 95) {
      return const Icon(Icons.battery_full, size: kSmallIconSize);
    } else if (value >= 85) {
      return const Icon(Icons.battery_6_bar, size: kSmallIconSize); // ~90%
    } else if (value >= 65) {
      return const Icon(Icons.battery_5_bar, size: kSmallIconSize); // ~80%
    } else if (value >= 45) {
      return const Icon(Icons.battery_4_bar, size: kSmallIconSize); // ~60%
    } else if (value >= 35) {
      return const Icon(Icons.battery_3_bar, size: kSmallIconSize); // ~50%
    } else if (value >= 25) {
      return const Icon(Icons.battery_2_bar, size: kSmallIconSize); // ~30%
    } else if (value >= 15) {
      return const Icon(Icons.battery_1_bar, size: kSmallIconSize); // ~20%
    } else {
      return const Icon(Icons.battery_0_bar, size: kSmallIconSize); // <15%
    }
  }
}
