import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/reader_direction.dart';
import 'package:hikari_novel_flutter/pages/reader/controller.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/custom_header.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/custom_slider.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/horizontal_read_page.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/reader_background.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/vertical_read_page.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
import 'package:intl/intl.dart';

import '../../common/constants.dart';
import '../../models/page_state.dart';
import '../../router/route_path.dart';

class ReaderPage extends StatelessWidget {
  ReaderPage({super.key});

  final controller = Get.put(ReaderController());

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
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent, //防止上下滚动事件被拦截，只拦截点击事件
                    onTap: () => controller.showBar.value = !controller.showBar.value,
                    child: ReaderBackground(
                      child: Obx(
                        () => Padding(
                          padding: EdgeInsets.only(
                            bottom: controller.readerSettingsState.value.showStatusBar ? kStatusBarPadding + MediaQuery.of(context).padding.bottom : 0,
                          ),
                          child: _buildReadPage(context),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
          Obx(() {
            final bool isEnabled =
                controller.pageState.value == PageState.success && controller.readerSettingsState.value.direction != ReaderDirection.upToDown;

            return isEnabled
                ? Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () =>
                                controller.readerSettingsState.value.direction == ReaderDirection.leftToRight ? controller.prevPage() : controller.nextPage(),
                            behavior: HitTestBehavior.translucent,
                          ),
                        ),
                        const Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () =>
                                controller.readerSettingsState.value.direction == ReaderDirection.leftToRight ? controller.nextPage() : controller.prevPage(),
                            behavior: HitTestBehavior.translucent,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container();
          }),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: const LoadingPage())),
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.error,
              child: ErrorMessage(msg: controller.errorMsg, onRetry: controller.getContent),
            ),
          ),
          _buildBottomStatusBar(context),
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
                child: Column(
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
    return SizedBox(
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
          controller.text.value,
          controller.images,
          initPosition: controller.isInitialized ? 0 : controller.getInitLocation(),
          padding: padding,
          style: textStyle,
          controller: controller.scrollController,
          onScroll: (position, max) {
            if (max == 0 && position == 0) {
              //仅一页的情况下
              controller.location.value = 0;
              controller.verticalProgress.value = 100;
              controller.setReadHistory(); //立即更新历史阅读记录
            } else if (max > 0) {
              controller.location.value = position.toInt();
              controller.verticalProgress.value = ((position.toInt() / max.toInt()) * 100).toInt();
              //由controller的debounce监听location变化，判断是否更新历史阅读记录
            }
          },
        ),
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
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
      child: HorizontalReadPage(
        controller.text.value,
        controller.images,
        initIndex: controller.isInitialized ? 0 : controller.getInitLocation(),
        padding: padding,
        style: textStyle,
        reverse: controller.readerSettingsState.value.direction == ReaderDirection.rightToLeft,
        isDualPage: controller.isDualPage,
        dualPageSpacing: controller.readerSettingsState.value.dualPageSpacing,
        controller: controller.pageController,
        onPageChanged: (index, max) {
          controller.currentIndex.value = index;
          controller.maxPage.value = max;
          if (max == 1 && index == 0) {
            //仅一页的情况下
            controller.horizontalProgress.value = 100;
            controller.setReadHistory(); //立即更新历史阅读记录
          } else if (max > 0) {
            controller.horizontalProgress.value = int.parse(((index + 1) / max * 100.0).toStringAsFixed(0));
            //由controller的debounce监听currentIndex变化，判断是否更新历史阅读记录
          }
        },
        onViewImage: (index) => Get.toNamed(RoutePath.photo, arguments: {"gallery_mode": true, "list": controller.images, "index": index}),
      ),
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
                    controller.scrollController.jumpTo(controller.scrollController.position.maxScrollExtent * (e / 100.0));
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
