import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/models/reader_direction.dart';
import 'package:hikari_novel_flutter/pages/novel_detail/controller.dart';
import 'package:hikari_novel_flutter/pages/novel_detail/widgets/bottom_text_icon_button.dart';
import 'package:hikari_novel_flutter/pages/novel_detail/widgets/icon_text.dart';
import 'package:hikari_novel_flutter/router/app_sub_router.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/service/db_service.dart';

import '../../network/request.dart';
import '../../service/local_storage_service.dart';
import '../../widgets/state_page.dart';

class NovelDetailPage extends StatefulWidget {
  final String aid;

  const NovelDetailPage({super.key, required this.aid});

  @override
  State<NovelDetailPage> createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage> {
  late final NovelDetailController controller;
  final RxDouble _opacity = 0.0.obs;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.delete<NovelDetailController>();
    controller = Get.put(NovelDetailController(aid: widget.aid));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => Offstage(offstage: controller.pageState.value != PageState.success, child: _buildPage(context))),
        Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: _buildLoadingPage())),
        Obx(
          () => Offstage(
            offstage: controller.pageState.value != PageState.error,
            child: ErrorMessage(msg: controller.errorMsg, onRetry: () => controller.getNovelDetail()),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingPage() => Scaffold(appBar: AppBar(), body: const LoadingPage());

  Widget _buildPage(BuildContext context) {
    return Obx(
      () => controller.novelDetail.value == null
          ? _buildLoadingPage()
          : Obx(
              () => Scaffold(
                extendBodyBehindAppBar: true,
                appBar: _buildAppBar(context),
                body: NotificationListener<Notification>(
                  onNotification: (Notification notification) {
                    if (notification is ScrollNotification) {
                      final double offset = notification.metrics.pixels;
                      _opacity.value = offset > 0 ? 1 : 0;
                    }
                    return false;
                  },
                  child: Obx(() {
                    //如果处于多选模式下，应该暂时移除刷新功能
                    return RefreshIndicator(
                      onRefresh: controller.isSelectionMode.value ? () async {} : controller.getNovelDetail,
                      edgeOffset: kToolbarHeight + MediaQuery.of(context).padding.top,
                      child: _buildContent(context),
                    );
                  }),
                ),
                floatingActionButton: _buildContinueFab(),
                bottomNavigationBar: _buildBottomBar(context),
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GetBuilder(
      id: "customScrollView",
      init: controller,
      builder: (_) => CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildInfo(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ExpandableText(
                controller.novelDetail.value!.introduce,
                maxLines: 3,
                expandText: "expand".tr,
                collapseText: "collapse".tr,
                linkColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.novelDetail.value!.tags.map((e) => Chip(label: Text(e), padding: const EdgeInsets.fromLTRB(8, 0, 8, 0))).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Obx(() {
              final value = controller.isChapterOrderReversed.value;
              return Row(
                children: [
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () {
                      controller.isChapterOrderReversed.toggle();
                      controller.update(["customScrollView"]); //通知重绘CustomScrollView
                    },
                    icon: value ? const Icon(Icons.arrow_upward) : const Icon(Icons.arrow_downward),
                    label: Text(value ? "descending".tr : "ascending".tr),
                  ),
                  const Spacer(),
                ],
              );
            }),
          ),
          _buildCatalogueSliver(context),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (controller.isSelectionMode.value) {
      return AppBar(
        automaticallyImplyLeading: false,
        leading: CloseButton(onPressed: controller.exitSelectionMode),
        title: Text(controller.getSelectedCount().toString()),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        titleSpacing: 0,
        actions: [
          IconButton(onPressed: controller.selectAll, icon: const Icon(Icons.select_all)),
          IconButton(onPressed: controller.deselect, icon: const Icon(Icons.deselect)),
        ],
      );
    }

    return AppBar(
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: _opacity.value == 0 ? Colors.transparent : Theme.of(context).colorScheme.surface,
      title: Obx(() => AnimatedOpacity(opacity: _opacity.value, duration: const Duration(milliseconds: 200), child: Text(controller.novelDetail.value!.title))),
      titleSpacing: 0,
      actions: [
        IconButton(onPressed: controller.enterSelectionMode, icon: Icon(Icons.download_outlined), tooltip: "cache".tr),
        PopupMenuButton<_MenuItem>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == _MenuItem.cacheQueue) {
              AppSubRouter.toCacheQueue();
            } else if (value == _MenuItem.deleteCache) {
              controller.deleteCache();
            } else if (value == _MenuItem.delAllReadHistory) {
              controller.deleteAllReadHistory();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: _MenuItem.cacheQueue, child: Text("view_cache_queue".tr)),
            PopupMenuItem(value: _MenuItem.deleteCache, child: Text("delete_cache".tr)),
            PopupMenuItem(value: _MenuItem.delAllReadHistory, child: Text("del_all_read_history".tr)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    final detail = controller.novelDetail.value!;
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Blur(
              blur: 3,
              blurColor: Theme.of(context).colorScheme.surface,
              child: CachedNetworkImage(
                width: double.infinity,
                imageUrl: detail.imgUrl,
                httpHeaders: Request.userAgent,
                fit: BoxFit.fitWidth,
                progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                errorWidget: (context, url, error) => Column(children: [const Icon(Icons.error_outline), Text(error.toString())]),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 1),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 10),
            Row(
              children: [
                const SizedBox(width: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
                  elevation: 0,
                  clipBehavior: Clip.hardEdge,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(RoutePath.photo, arguments: {"gallery_mode": false, "url": detail.imgUrl}),
                    child: CachedNetworkImage(
                      width: 120,
                      height: 180,
                      imageUrl: detail.imgUrl,
                      httpHeaders: Request.userAgent,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                      errorWidget: (context, url, error) => Column(children: [const Icon(Icons.error_outline), Text(error.toString())]),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => AppSubRouter.toSearch(author: detail.author),
                        child: IconText(icon: Icons.person_outline, text: detail.author, color: Theme.of(context).colorScheme.primary, bold: true),
                      ),
                      const SizedBox(height: 4),
                      IconText(icon: Icons.schedule, text: detail.status),
                      const SizedBox(height: 4),
                      IconText(icon: Icons.update, text: detail.finUpdate),
                      const SizedBox(height: 4),
                      IconText(icon: Icons.tv, text: detail.isAnimated ? "animated".tr : "unanimated".tr),
                      const SizedBox(height: 4),
                      IconText(icon: Icons.local_fire_department_outlined, text: detail.heat),
                      const SizedBox(height: 4),
                      IconText(icon: Icons.trending_up, text: detail.trending),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Obx(
                    () => BottomTextIconButton(
                      label: controller.isInBookshelf.value ? "favorited".tr : "favorite".tr,
                      icon: controller.isInBookshelf.value ? Icons.favorite : Icons.favorite_outline,
                      onPressed: () => controller.isInBookshelf.value ? controller.removeFromBookshelf() : controller.addToBookshelf(),
                    ),
                  ),
                  BottomTextIconButton(label: "recommend".tr, icon: Icons.recommend_outlined, onPressed: controller.recommendThisNovel),
                  BottomTextIconButton(label: "Web", icon: Icons.public, onPressed: controller.openWithBrowser),
                  BottomTextIconButton(
                    label: "comment".tr,
                    icon: Icons.comment_outlined,
                    onPressed: () => AppSubRouter.toComment(aid: widget.aid),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  //将目录构建为一个 Sliver（每个卷作为一个 item）
  Widget _buildCatalogueSliver(BuildContext context) {
    final detail = controller.novelDetail.value!;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, volumeIndex) {
        if (controller.isChapterOrderReversed.value) volumeIndex = detail.catalogue.length - volumeIndex - 1;
        final volume = detail.catalogue[volumeIndex];
        final volumeCids = volume.chapters.map((catChapter) => catChapter.cid).toList();
        final totalChaps = volume.chapters.length;

        //每个卷用一个 Card/ExpansionTile 表示；内部章节使用 ListTile 列表
        return StreamBuilder(
          stream: DBService.instance.getWatchableReadHistoryByVolume(volumeCids),
          builder: (context, volumeSnapshot) => Obx(() {
            final selectedChaps = volume.chapters.where((c) => c.isSelected.value).length;
            final isPartiallySelected = selectedChaps > 0 && selectedChaps < totalChaps;
            final bool? volumeCheckboxValue = selectedChaps == totalChaps && totalChaps > 0 ? true : (isPartiallySelected ? null : false);

            final volumeSubtitle = controller.getReadHistoryProgressByVolume(volumeSnapshot.data ?? [], volume.chapters.length);

            Color volumeTitleColor = Theme.of(context).colorScheme.onSurface; // 默认颜色
            Color volumeSubtitleColor = Theme.of(context).colorScheme.primary;

            if (volumeSubtitle == "all_reading_completed".tr) {
              volumeTitleColor = Theme.of(context).disabledColor; // 已读完，字体变灰
              volumeSubtitleColor = Theme.of(context).disabledColor;
            }

            return GestureDetector(
              onLongPress: () {
                if (!controller.isSelectionMode.value) {
                  controller.enterSelectionMode();
                  controller.toggleVolumeSelection(volumeIndex);
                }
              },
              child: ExpansionTile(
                key: PageStorageKey("volume_$volumeIndex"),
                shape: const Border(),
                leading: controller.isSelectionMode.value
                    ? Checkbox(
                        tristate: true,
                        value: volumeCheckboxValue,
                        onChanged: (bool? v) {
                          final makeSelected = v == true;
                          final volumeRef = controller.novelDetail.value!.catalogue[volumeIndex];
                          for (final c in volumeRef.chapters) {
                            c.isSelected.value = makeSelected;
                          }
                        },
                      )
                    : null,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(volume.title, style: TextStyle(fontSize: 15, color: volumeTitleColor)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(volumeSubtitle, style: TextStyle(fontSize: 13, color: volumeSubtitleColor)),
                ),
                children: volume.chapters.asMap().entries.map((entry) {
                  final chapterIndex = entry.key;
                  final chapter = entry.value;

                  controller.checkIsChapterCached(chapter.cid); //检测当前章节是否已缓存

                  //使用FutureBuilder处理异步的阅读历史数据
                  return StreamBuilder(
                    stream: DBService.instance.getWatchableReadHistoryByCid(chapter.cid),
                    builder: (context, chapterSnapshot) {
                      return Obx(() {
                        Color chapterTitleColor = Theme.of(context).colorScheme.onSurface; // 默认颜色
                        Color chapterSubtitleColor = Theme.of(context).colorScheme.primary;

                        final readHistory = chapterSnapshot.data;
                        if (readHistory != null && readHistory.progress == 100) {
                          chapterTitleColor = Theme.of(context).disabledColor; // 已读完，字体变灰
                          chapterSubtitleColor = Theme.of(context).disabledColor;
                        }

                        var cacheString = controller.cachedChapter.contains(chapter.cid) ? " • ${"cached".tr}" : "";
                        var lastReadString = readHistory?.isLatest == true ? "${"last_read".tr} • " : "";

                        return ListTile(
                          leading: controller.isSelectionMode.value
                              ? Checkbox(value: chapter.isSelected.value, onChanged: (_) => controller.toggleChapterSelection(volumeIndex, chapterIndex))
                              : null,
                          title: Text(chapter.title, style: TextStyle(fontSize: 13, color: chapterTitleColor)),
                          subtitle: Text(
                            lastReadString + controller.getReadHistoryProgressByCid(chapterSnapshot.data) + cacheString,
                            style: TextStyle(fontSize: 13, color: chapterSubtitleColor),
                            overflow: TextOverflow.clip,
                          ),
                          contentPadding: const EdgeInsets.only(left: 50.0, right: 24.0),
                          onTap: () async {
                            if (controller.isSelectionMode.value) {
                              controller.toggleChapterSelection(volumeIndex, chapterIndex);
                              return;
                            }

                            //获取上次阅读的位置
                            final history = await DBService.instance.getReadHistoryByCid(chapter.cid);
                            var location = 0; //没有记录或者有不适用的记录则从头开始阅读（即阅读位置为0）
                            final currDirection = LocalStorageService.instance.getReaderDirection();
                            if ((history?.readerMode == kScrollReadMode && currDirection == ReaderDirection.upToDown) ||
                                (history?.readerMode == kPageReadMode &&
                                    (currDirection == ReaderDirection.leftToRight || currDirection == ReaderDirection.rightToLeft))) {
                              location = history?.location ?? 0;
                            }
                            Get.toNamed(RoutePath.reader, parameters: {"cid": chapter.cid, "location": "$location"});
                          },
                          onLongPress: () {
                            if (!controller.isSelectionMode.value) controller.enterSelectionMode();
                            controller.toggleChapterSelection(volumeIndex, chapterIndex);
                          },
                        );
                      });
                    },
                  );
                }).toList(),
              ),
            );
          }),
        );
      }, childCount: detail.catalogue.length),
    );
  }

  Widget _buildContinueFab() {
    return Obx(
      () => Offstage(
        offstage: controller.isSelectionMode.value,
        child: StreamBuilder(
          stream: DBService.instance.getLastestReadHistoryByAid(controller.aid),
          builder: (_, snapshot) {
            if (snapshot.data == null && !controller.isValidReadHistory(snapshot.data)) {
              return Container();
            }
            final history = snapshot.data;
            return FloatingActionButton.extended(
              onPressed: () {
                if (history == null) return;
                Get.toNamed(RoutePath.reader, parameters: {"cid": history.cid, "location": "${history.location}"});
              },
              label: Row(children: [const Icon(Icons.play_arrow), const SizedBox(width: 10), Text("continue_reading".tr)]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return Obx(
      () => Offstage(
        offstage: !controller.isSelectionMode.value,
        child: BottomAppBar(
          height: 72,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    await controller.startCache();
                    controller.exitSelectionMode();
                    AppSubRouter.toCacheQueue();
                  },
                  icon: Icon(Icons.download_outlined, color: onSurfaceColor),
                  label: Text("cache".tr, style: TextStyle(color: onSurfaceColor)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    await controller.markAsRead();
                    controller.exitSelectionMode();
                  },
                  icon: Icon(Icons.done_all, color: onSurfaceColor),
                  label: Text("mark_as_read".tr, style: TextStyle(color: onSurfaceColor)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    await controller.markAsUnRead();
                    controller.exitSelectionMode();
                  },
                  icon: Icon(Icons.remove_done, color: onSurfaceColor),
                  label: Text("mark_as_unread".tr, style: TextStyle(color: onSurfaceColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MenuItem { deleteCache, cacheQueue, delAllReadHistory }
