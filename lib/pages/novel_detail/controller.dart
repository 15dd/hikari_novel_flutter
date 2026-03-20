import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/models/chapter_cache_task.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/novel_detail.dart';
import 'package:hikari_novel_flutter/models/reader_direction.dart';
import 'package:hikari_novel_flutter/network/parser.dart';
import 'package:hikari_novel_flutter/pages/bookshelf/controller.dart';
import 'package:hikari_novel_flutter/pages/cache_queue/controller.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/database/database.dart';
import '../../models/cat_chapter.dart';
import '../../models/dual_page_mode.dart';
import '../../models/page_state.dart';
import '../../models/resource.dart';
import '../../network/api.dart';
import '../../service/db_service.dart';
import '../../service/local_storage_service.dart';

class NovelDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  final String aid;

  NovelDetailController({required this.aid});

  Rx<PageState> pageState = PageState.loading.obs;
  String errorMsg = "";
  Rxn<NovelDetail> novelDetail = Rxn();

  RxSet<String> cachedChapter = RxSet();

  RxBool isInBookshelf = false.obs;

  RxBool isChapterOrderReversed = false.obs;

  RxBool isSelectionMode = false.obs;

  bool _isFabVisible = true;
  late final AnimationController _fabAnimationCtr;
  late final Animation<Offset> animation;

  final bookshelfController = Get.find<BookshelfController>();
  final cacheQueueController = Get.findOrPut(() => CacheQueueController());

  late final Directory _supportDir;

  @override
  void onInit() {
    super.onInit();
    _fabAnimationCtr = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..forward();
    animation = _fabAnimationCtr.drive(Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)));
  }

  @override
  void onReady() async {
    super.onReady();
    _supportDir = await getApplicationSupportDirectory();
    getNovelDetail();
  }

  @override
  void onClose() {
    _fabAnimationCtr.dispose();
    super.onClose();
  }

  void showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      _fabAnimationCtr.forward();
    }
  }

  void hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      _fabAnimationCtr.reverse();
    }
  }

  void enterSelectionMode() => isSelectionMode.value = true;

  void exitSelectionMode() {
    isSelectionMode.value = false;
    deselect();
  }

  //切换某个章节的选中状态（假设 chapter.isSelected 是 RxBool）
  void toggleChapterSelection(int volumeIndex, int chapterIndex) {
    final chapter = novelDetail.value!.catalogue[volumeIndex].chapters[chapterIndex];
    chapter.isSelected.toggle();
    _syncVolumeSelection(volumeIndex);
  }

  //切换某卷（全部选中或全部取消）
  void toggleVolumeSelection(int volumeIndex) {
    final volume = novelDetail.value!.catalogue[volumeIndex];
    final allSelected = volume.chapters.every((c) => c.isSelected.value);
    for (final c in volume.chapters) {
      c.isSelected.value = !allSelected;
    }
    volume.isSelected.value = !allSelected;
  }

  //根据章节选中数同步卷状态
  void _syncVolumeSelection(int volumeIndex) {
    final volume = novelDetail.value!.catalogue[volumeIndex];
    final total = volume.chapters.length;
    final selected = volume.chapters.where((c) => c.isSelected.value).length;
    if (selected == 0) {
      volume.isSelected.value = false;
    } else if (selected == total) {
      volume.isSelected.value = true;
    } else {
      //部分选中：你可以用单独字段或在 UI 用 selected数判断
      volume.isSelected.value = false;
    }
  }

  //获取选中的章节列表
  List<CatChapter> getSelectedChapters() {
    final out = <CatChapter>[];
    final detail = novelDetail.value;
    if (detail == null) return out;
    for (final vol in detail.catalogue) {
      for (final ch in vol.chapters) {
        if (ch.isSelected.value) out.add(ch);
      }
    }
    return out;
  }

  int getSelectedCount() => getSelectedChapters().length;

  void deselect() {
    final detail = novelDetail.value;
    if (detail == null) return;
    for (final vol in detail.catalogue) {
      vol.isSelected.value = false;
      for (final ch in vol.chapters) {
        ch.isSelected.value = false;
      }
    }
  }

  void selectAll() {
    final detail = novelDetail.value;
    if (detail == null) return;
    for (final vol in detail.catalogue) {
      vol.isSelected.value = true;
      for (final ch in vol.chapters) {
        ch.isSelected.value = true;
      }
    }
  }

  Future<void> startCache() async {
    for (var chap in getSelectedChapters()) {
      await cacheQueueController.addTask(
        ChapterCacheTask(
          uuid: "${aid}_${chap.cid}",
          aid: aid,
          cid: chap.cid,
          title: chap.title,
          onCompleted: (cid) {
            cachedChapter.add(cid);
          },
        ),
      );
    }
  }

  Future<void> deleteCache() async {
    final asd = await getApplicationSupportDirectory();
    final dir = Directory("${asd.path}/cached_chapter");

    if (!await dir.exists()) {
      return;
    }

    await for (var entity in dir.list()) {
      if (entity is File) {
        final fileName = entity.uri.pathSegments.last;

        if (fileName.contains("_")) {
          final prefix = fileName.split("_").first;
          final last = fileName.split("_").last;

          final number = int.tryParse(prefix);
          if (number != null && number == int.parse(aid)) {
            try {
              await entity.delete();
            } catch (e) {
              null;
            }
          }
          cachedChapter.remove(last);
        }
      }
    }
  }

  void checkIsChapterCached(String cid) async {
    if (await File("${_supportDir.path}/cached_chapter/${aid}_$cid.txt").exists()) {
      cachedChapter.add(cid);
    } else {
      cachedChapter.remove(cid);
    }
  }

  Future<void> getNovelDetail() async {
    late NovelDetail data;

    final nd = await Api.getNovelDetail(aid: aid);

    switch (nd) {
      case Success():
        data = Parser.getNovelDetail(nd.data);
        final cat = await Api.getCatalogue(aid: aid);
        switch (cat) {
          case Success():
            {
              data.catalogue.addAll(Parser.getCatalogue(cat.data));
              novelDetail.value = data;

              DBService.instance.upsertBrowsingHistory(BrowsingHistoryEntityData(aid: aid, title: data.title, img: data.imgUrl, time: DateTime.now()));

              final bs = await DBService.instance.getAllBookshelf();
              isInBookshelf.value = bs.any((e) => e.aid == aid);

              pageState.value = PageState.success;
              await DBService.instance.upsertNovelDetail(NovelDetailEntityData(aid: aid, json: novelDetail.value!.toString())); //缓存小说详情
            }
          case Error():
            {
              //检测本地是否有缓存
              if (await _getNovelDetailByLocal()) return;
              errorMsg = cat.error.toString();
              pageState.value = PageState.error;
            }
        }
      case Error():
        {
          //检测本地是否有缓存
          if (await _getNovelDetailByLocal()) return;
          errorMsg = nd.error.toString();
          pageState.value = PageState.error;
        }
    }
  }

  Future<bool> _getNovelDetailByLocal() async {
    final local = (await DBService.instance.getNovelDetail(aid))?.json;

    if (local == null) {
      return false;
    } else {
      novelDetail.value = NovelDetail.fromString(local);
      pageState.value = PageState.success;
      return true;
    }
  }

  bool _isAdding = false; //防抖
  void addToBookshelf() async {
    if (_isAdding) return;
    _isAdding = true;
    final result = await Api.addNovel(aid: aid);
    switch (result) {
      case Success():
        {
          if (Parser.isError(result.data)) {
            Get.dialog(
              AlertDialog(
                icon: const Icon(Icons.warning_amber_outlined),
                title: Text("warning".tr),
                content: Text("add_to_bookshelf_failed_tip".tr),
                actions: [TextButton(onPressed: Get.back, child: Text("confirm".tr))],
              ),
            );
            isInBookshelf.value = false;
          } else {
            await bookshelfController.refreshDefaultBookshelf();
            isInBookshelf.value = true;
          }
        }
      case Error():
        {
          showErrorDialog(result.error.toString(), [TextButton(onPressed: Get.back, child: Text("confirm".tr))]);
        }
    }
    _isAdding = false;
  }

  bool _isRemoving = false; //防抖
  void removeFromBookshelf() async {
    if (_isRemoving) return;
    _isRemoving = true;
    final bs = await DBService.instance.getAllBookshelf();
    final delId = bs.firstWhere((i) => i.aid == aid).bid;
    final result = await Api.removeNovel(delid: delId);
    switch (result) {
      case Success():
        {
          isInBookshelf.value = false;
        }
      case Error():
        {
          showErrorDialog(result.error.toString(), [TextButton(onPressed: Get.back, child: Text("confirm".tr))]);
        }
    }
    _isRemoving = false;
  }

  void recommendThisNovel() async {
    final result = await Api.novelVote(aid: aid);
    final string = switch (result) {
      Success() => Parser.novelVote(result.data),
      Error() => result.error.toString(),
    };
    showSnackBar(message: string, context: Get.context!);
  }

  Future<void> openWithBrowser() async {
    if (!await launchUrl(Uri.parse("${Api.wenku8Node.node}/book/$aid.htm"))) {
      showSnackBar(message: "unable_to_open_external_browser".tr, context: Get.context!);
    }
  }

  ///检测阅读记录是否适用于当前设置（是否双页，阅读方向）
  bool isValidReadHistory(ReadHistoryEntityData? data) {
    if (data == null) {
      return false;
    } else {
      bool isDualPage = switch (LocalStorageService.instance.getReaderDualPageMode()) {
        DualPageMode.auto => Get.context!.isLargeScreen(),
        DualPageMode.enabled => true,
        DualPageMode.disabled => false,
      };
      return data.isDualPage == isDualPage && data.readerMode == LocalStorageService.instance.getReaderDirection().index;
    }
  }

  String getReadHistoryProgressByCid(ReadHistoryEntityData? result) {
    if (result == null) {
      return "unread".tr;
    }

    bool isDualPage = switch (LocalStorageService.instance.getReaderDualPageMode()) {
      DualPageMode.auto => Get.context!.isLargeScreen(),
      DualPageMode.enabled => true,
      DualPageMode.disabled => false,
    };

    final currDirection = LocalStorageService.instance.getReaderDirection();
    if (result.isDualPage == isDualPage) {
      if ((result.readerMode == kScrollReadMode && currDirection == ReaderDirection.upToDown) ||
          (result.readerMode == kPageReadMode && (currDirection == ReaderDirection.leftToRight || currDirection == ReaderDirection.rightToLeft))) {
        return "${result.progress}%";
      }
    }
    return "unable_to_use_read_history_tip".tr;
  }

  String getReadHistoryProgressByVolume(List<ReadHistoryEntityData> list, int totalNum) {
    int readCompletedNum = 0;
    int readPartiallyNum = 0;

    if (list.isEmpty) {
      return "unread".tr;
    }

    bool isDualPage = switch (LocalStorageService.instance.getReaderDualPageMode()) {
      DualPageMode.auto => Get.context!.isLargeScreen(),
      DualPageMode.enabled => true,
      DualPageMode.disabled => false,
    };
    final currDirection = LocalStorageService.instance.getReaderDirection();
    for (ReadHistoryEntityData d in list) {
      if (d.isDualPage == isDualPage) {
        if ((d.readerMode == kScrollReadMode && currDirection == ReaderDirection.upToDown) ||
            (d.readerMode == kPageReadMode && (currDirection == ReaderDirection.leftToRight || currDirection == ReaderDirection.rightToLeft))) {
          if (d.progress == 100) {
            readCompletedNum++;
          } else {
            readPartiallyNum++;
          }
        }
      }
    }

    if (readCompletedNum == totalNum) {
      return "all_reading_completed".tr;
    } else if (readPartiallyNum > 0 || (readCompletedNum > 0 && readCompletedNum < totalNum)) {
      return "partially_read".tr;
    } else {
      return "unread".tr;
    }
  }

  void deleteAllReadHistory() async => DBService.instance.deleteAllReadHistory();

  Future<void> markAsUnRead() async {
    for (var chapter in getSelectedChapters()) {
      await DBService.instance.deleteReadHistoryByCid(chapter.cid);
    }
  }

  Future<void> markAsRead() async {
    // 1为滚动模式，2为翻页模式，翻页模式的左右方向不影响阅读记录的使用
    final readerMode = LocalStorageService.instance.getReaderDirection() == ReaderDirection.upToDown ? kScrollReadMode : kPageReadMode;
    bool isDualPage = switch (LocalStorageService.instance.getReaderDualPageMode()) {
      DualPageMode.auto => Get.context!.isLargeScreen(),
      DualPageMode.enabled => true,
      DualPageMode.disabled => false,
    };

    for (var chapter in getSelectedChapters()) {
      final data = await DBService.instance.getReadHistoryByCid(chapter.cid);

      if (data == null) {
        DBService.instance.upsertReadHistoryDirectly(
          ReadHistoryEntityData(cid: chapter.cid, aid: aid, readerMode: readerMode, isDualPage: isDualPage, location: 0, progress: 100, isLatest: false),
        );
      } else {
        DBService.instance.upsertReadHistoryDirectly(
          ReadHistoryEntityData(
            cid: data.cid,
            aid: data.aid,
            readerMode: data.readerMode,
            isDualPage: data.isDualPage,
            location: data.location,
            progress: 100,
            isLatest: data.isLatest,
          ),
        );
      }
    }
  }
}
