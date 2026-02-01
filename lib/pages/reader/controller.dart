import 'dart:io';
import 'dart:isolate';

import 'package:battery_plus/battery_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/models/dual_page_mode.dart';
import 'package:hikari_novel_flutter/models/reader_direction.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/network/parser.dart';
import 'package:hikari_novel_flutter/pages/novel_detail/controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ttf_metadata/ttf_metadata.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../common/database/database.dart';
import '../../common/log.dart';
import '../../models/cat_volume.dart';
import '../../models/page_state.dart';
import '../../network/api.dart';
import '../../service/db_service.dart';
import '../../service/local_storage_service.dart';

class ReaderController extends GetxController {
  final _novelDetailController = Get.find<NovelDetailController>();

  late List<CatVolume> catalogue;
  late String aid;
  late int currentVolumeIndex;
  late int currentChapterIndex;

  String get cid => catalogue[currentVolumeIndex].chapters[currentChapterIndex].cid;

  int get currentChapterTotal => catalogue[currentVolumeIndex].chapters.length;

  int get currentVolumeTotal => catalogue.length;

  final pageController = PageController();
  final scrollController = ScrollController();

  final _battery = Battery();
  RxInt batteryLevel = 0.obs;

  Rx<PageState> pageState = Rx(PageState.loading);

  Rx<ReaderSettingsState> readerSettingsState = Rx(ReaderSettingsState.init());

  ///阅读界面显示操作栏
  RxBool showBar = false.obs;

  bool get isDualPage => switch (readerSettingsState.value.dualPageMode) {
    DualPageMode.auto => Get.context!.isLargeScreen(),
    DualPageMode.enabled => true,
    DualPageMode.disabled => false,
  };

  RxString chapterTitle = "".obs;

  ///当前页面，横向用
  RxInt currentIndex = 0.obs;

  RxInt horizontalProgress = 0.obs;

  ///最大页面
  RxInt maxPage = 0.obs;

  ///阅读位置，竖向用
  RxInt location = 0.obs;

  ///竖向模式下，显示当前阅读进度的百分比
  RxInt verticalProgress = 0.obs;

  ///文本内容
  RxString text = "".obs;

  RxList<String> images = RxList();

  String errorMsg = "";

  RxBool isFontFileAvailable = false.obs;

  Rxn<Color> currentTextColor = Rxn();

  Rxn<Color> currentBgColor = Rxn();

  String? textFamilyName;

  Rxn<String> currentBgImagePath = Rxn();

  bool isInitialized = false;

  @override
  void onInit() async {
    super.onInit();

    aid = _novelDetailController.aid;
    catalogue = _novelDetailController.novelDetail.value!.catalogue;

    _battery.batteryLevel.then((l) => batteryLevel.value = l);
    _battery.onBatteryStateChanged.listen((l) async {
      batteryLevel.value = await _battery.batteryLevel;
    });

    getTextColor();
    getBgColor();
    getBgImage();

    checkFontFile(true);

    //延迟更新阅读记录
    //debounce / ever / interval 只能在 Controller 生命周期里创建一次
    //TODO 还需要优化
    interval(location, (_) async => setReadHistory(), time: const Duration(milliseconds: 500));
    interval(currentIndex, (_) async => setReadHistory(), time: const Duration(milliseconds: 500));
  }

  @override
  void onReady() async {
    super.onReady();
    if (readerSettingsState.value.wakeLock) WakelockPlus.toggle(enable: true);
    if (readerSettingsState.value.immersionMode) SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    /*
     1) 至于这里的cid为什么不直接使用上面的<get cid>，是因为上面的<get cid>依赖currentVolumeIndex和currentChapterIndex。
        而我们想要currentVolumeIndex和currentChapterIndex的时候，需要根据cid在catalogue中获取其对应的VolumeIndex和ChapterIndex。
     2) 因为getContent()函数依赖cid，所以我把初始化cid的过程放到了onReady而不是onInit中。
     */
    final listOnlyWithCid = catalogue.map((cat) => cat.chapters.map((chap) => chap.cid).toList()).toList(); //仅提取含有cid的list
    final targetCid = Get.parameters["cid"]!;
    final indexPosition = (await compute(_findIndexPositionInCatalogue, {'catalogue': listOnlyWithCid, 'cid': targetCid}))!;

    currentVolumeIndex = indexPosition[0];
    currentChapterIndex = indexPosition[1];

    chapterTitle.value = catalogue[currentVolumeIndex].chapters[currentChapterIndex].title;

    await getContent();
  }

  @override
  void onClose() {
    if (readerSettingsState.value.wakeLock) WakelockPlus.toggle(enable: false);
    if (readerSettingsState.value.immersionMode) SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }

  //获取初始页面位置
  int getInitLocation() {
    isInitialized = true;
    if (readerSettingsState.value.direction == ReaderDirection.upToDown) {
      try {
        int value = int.parse(Get.parameters["location"]!);
        location.value = value;
        return value;
      } catch (_) {
        return 0;
      }
    } else {
      try {
        int value = int.parse(Get.parameters["location"]!);
        currentIndex.value = value;
        return value;
      } catch (_) {
        return 0;
      }
    }
  }

  Stream<DateTime> clockStream() => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

  Future<void> getContent() async {
    pageState.value = PageState.loading;

    chapterTitle.value = "";
    final chapter = await _getChapterContentFromLocal();
    chapter == null ? _getContentByNetwork() : _getContentByLocal(chapter);
  }

  Future<String?> _getChapterContentFromLocal() async {
    final dir = await getApplicationSupportDirectory();
    final file = File("${dir.path}/cached_chapter/${aid}_$cid.txt");
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  Future<void> _getContentByNetwork() async {
    final result = await Api.getNovelContent(aid: aid, cid: cid);
    switch (result) {
      case Success():
        {
          final content = await compute(Parser.getContent, result.data as String);
          images.value = content.images;
          chapterTitle.value = catalogue[currentVolumeIndex].chapters[currentChapterIndex].title;
          text.value = content.text;

          pageState.value = PageState.success;
        }
      case Error():
        {
          errorMsg = result.error.toString();
          pageState.value = PageState.error;
        }
    }
  }

  Future<void> _getContentByLocal(String result) async {
    final content = await compute(Parser.getContent, result);
    images.value = content.images;
    chapterTitle.value = catalogue[currentVolumeIndex].chapters[currentChapterIndex].title;
    text.value = content.text;
    pageState.value = PageState.success;
  }

  /// 下一页
  void nextPage() {
    var value = currentIndex.value;
    var max = maxPage.value;
    if (value >= max - 1) {
      nextChapter();
    } else {
      jumpToPage(value + 1);
    }
  }

  /// 上一页
  void prevPage() {
    var value = currentIndex.value;
    if (value == 0) {
      prevChapter();
    } else {
      jumpToPage(value - 1);
    }
  }

  /// 跳转页数
  void jumpToPage(int page) {
    readerSettingsState.value.pageTurningAnimation
        ? pageController.animateToPage(page, duration: const Duration(milliseconds: 200), curve: Curves.linear)
        : pageController.jumpToPage(page);
  }

  void nextChapter() {
    if (currentVolumeIndex + 1 == currentVolumeTotal && currentChapterIndex + 1 == currentChapterTotal) {
      Get.dialog(
        AlertDialog(
          icon: Icon(Icons.warning_amber),
          title: Text("warning".tr),
          content: Text("no_next_chapter".tr),
          actions: [TextButton(onPressed: () => Get.back(), child: Text("confirm".tr))],
        ),
      );
    } else {
      if (currentVolumeIndex + 1 != currentVolumeTotal && currentChapterIndex + 1 == currentChapterTotal) {
        currentVolumeIndex++;
        currentChapterIndex = 0;
      } else {
        currentChapterIndex++;
      }

      getContent();
    }
  }

  void prevChapter() {
    if (currentVolumeIndex - 1 == -1 && currentChapterIndex - 1 == -1) {
      Get.dialog(
        AlertDialog(
          icon: Icon(Icons.warning_amber),
          title: Text("warning".tr),
          content: Text("no_previous_chapter".tr),
          actions: [TextButton(onPressed: Get.back, child: Text("confirm".tr))],
        ),
      );
    } else {
      if (currentVolumeIndex - 1 != -1 && currentChapterIndex - 1 == -1) {
        currentVolumeIndex--;
        currentChapterIndex = currentChapterTotal - 1;
      } else {
        currentChapterIndex--;
      }

      getContent();
    }
  }

  void setReadHistory() {
    Log.d("setReadHistory");
    DBService.instance.upsertReadHistory(
      ReadHistoryEntityData(
        cid: cid,
        aid: aid,
        readerMode: readerSettingsState.value.direction == ReaderDirection.upToDown ? kScrollReadMode : kPageReadMode,
        // 1为滚动模式，2为翻页模式，翻页模式的左右方向不影响阅读记录的使用
        isDualPage: isDualPage,
        location: readerSettingsState.value.direction == ReaderDirection.upToDown ? location.value : currentIndex.value,
        progress: readerSettingsState.value.direction == ReaderDirection.upToDown ? verticalProgress.value : horizontalProgress.value,
        isLatest: true,
      ),
    );
  }

  void changeFontSize(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(fontSize: value);
    LocalStorageService.instance.setReaderFontSize(value);
  }

  void changeLineSpacing(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(lineSpacing: value);
    LocalStorageService.instance.setReaderLineSpacing(value);
  }

  void changeReaderDirection(ReaderDirection d) {
    readerSettingsState.value = readerSettingsState.value.copyWith(direction: d);
    LocalStorageService.instance.setReaderDirection(d);
  }

  void changeReaderPageTurningAnimation(bool enabled) {
    readerSettingsState.value = readerSettingsState.value.copyWith(pageTurningAnimation: enabled);
    LocalStorageService.instance.setReaderPageTurningAnimation(enabled);
  }

  void changeReaderWakeLock(bool enabled) {
    readerSettingsState.value = readerSettingsState.value.copyWith(wakeLock: enabled);
    WakelockPlus.toggle(enable: enabled);
    LocalStorageService.instance.setReaderWakeLock(enabled);
  }

  void changeLeftMargin(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(leftMargin: value);
    LocalStorageService.instance.setReaderLeftMargin(value);
  }

  void changeTopMargin(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(topMargin: value);
    LocalStorageService.instance.setReaderTopMargin(value);
  }

  void changeRightMargin(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(rightMargin: value);
    LocalStorageService.instance.setReaderRightMargin(value);
  }

  void changeBottomMargin(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(bottomMargin: value);
    LocalStorageService.instance.setReaderBottomMargin(value);
  }

  void changeDualPageMode(DualPageMode mode) {
    readerSettingsState.value = readerSettingsState.value.copyWith(dualPageMode: mode);
    LocalStorageService.instance.setReaderDualPageMode(mode);
  }

  void changeDualPageSpacing(double value) {
    readerSettingsState.value = readerSettingsState.value.copyWith(dualPageSpacing: value);
    LocalStorageService.instance.setReaderDualPageSpacing(value);
  }

  void changeImmersionMode(bool enabled) {
    readerSettingsState.value = readerSettingsState.value.copyWith(immersionMode: enabled);
    if (enabled) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    LocalStorageService.instance.setReaderImmersionMode(enabled);
  }

  void changeShowStatusBar(bool enabled) {
    readerSettingsState.value = readerSettingsState.value.copyWith(showStatusBar: enabled);
    LocalStorageService.instance.setReaderStatusBar(enabled);
  }

  void changeReaderTextStyleFilePath(String? path) {
    readerSettingsState.value = readerSettingsState.value.copyWith(textStyleFilePath: path);
    LocalStorageService.instance.setReaderTextStyleFilePath(path);
  }

  void changeReaderTextFamily(String? family) {
    readerSettingsState.value = readerSettingsState.value.copyWith(textFamily: family);
    LocalStorageService.instance.setReaderTextFamily(family);
  }

  void changeReaderDayTextColor(Color? color) {
    currentTextColor.value = color;
    LocalStorageService.instance.setReaderDayTextColor(color);
  }

  void changeReaderNightTextColor(Color? color) {
    currentTextColor.value = color;
    LocalStorageService.instance.setReaderNightTextColor(color);
  }

  void changeReaderDayBgColor(Color? color) {
    currentBgColor.value = color;
    LocalStorageService.instance.setReaderDayBgColor(color);
  }

  void changeReaderNightBgColor(Color? color) {
    currentBgColor.value = color;
    LocalStorageService.instance.setReaderNightBgColor(color);
  }

  void changeReaderDayBgImage(String? path) {
    currentBgImagePath.value = path;
    LocalStorageService.instance.setReaderDayBgImage(path);
  }

  void changeReaderNightBgImage(String? path) {
    currentBgImagePath.value = path;
    LocalStorageService.instance.setReaderNightBgImage(path);
  }

  void getTextColor() {
    if (Get.context!.isDarkMode) {
      currentTextColor.value = LocalStorageService.instance.getReaderNightTextColor();
    } else {
      currentTextColor.value = LocalStorageService.instance.getReaderDayTextColor();
    }
  }

  void getBgColor() {
    if (Get.context!.isDarkMode) {
      currentBgColor.value = LocalStorageService.instance.getReaderNightBgColor();
    } else {
      currentBgColor.value = LocalStorageService.instance.getReaderDayBgColor();
    }
  }

  Future<bool?> pickTextStyleFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['ttf', 'otf']);
      if (result == null) return null; // 用户取消

      final tempPath = result.files.single.path!;

      await deleteFontDir();

      final srcFile = File(tempPath);
      final ext = path.extension(tempPath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "font_$timestamp$ext";
      final appDir = await getApplicationSupportDirectory();
      final destDir = Directory('${appDir.path}/font');
      await destDir.create(recursive: true);
      final destPath = '${destDir.path}/$fileName';
      final destFile = await srcFile.copy(destPath);

      final bytes = await File(tempPath).readAsBytes();
      textFamilyName = TtfMetadata(TtfDataSource(byteData: bytes)).fontName;

      await _loadFont(destFile);

      changeReaderTextStyleFilePath(destPath);
      changeReaderTextFamily(textFamilyName!);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadFont(File file) async {
    final bytes = await file.readAsBytes();
    textFamilyName = TtfMetadata(TtfDataSource(byteData: bytes)).fontName;
    final loader = FontLoader(textFamilyName!)..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  Future<void> deleteFontDir() async {
    final appDir = await getApplicationSupportDirectory();
    final fontsDir = Directory('${appDir.path}/fonts');

    if (await fontsDir.exists()) {
      await fontsDir.delete(recursive: true);
    }
  }

  //检查字体文件是否存在
  void checkFontFile(bool showDialog) async {
    if (readerSettingsState.value.textStyleFilePath != null && readerSettingsState.value.textFamily != null) {
      final result = await File(readerSettingsState.value.textStyleFilePath!).exists();
      if (result) {
        await _loadFont(File(readerSettingsState.value.textStyleFilePath!));
        isFontFileAvailable.value = true;
      } else {
        await deleteFontDir();
        changeReaderTextFamily(null);
        changeReaderTextStyleFilePath(null);
        isFontFileAvailable.value = false;

        if (showDialog) {
          Get.dialog(
            AlertDialog(
              icon: Icon(Icons.warning_amber_outlined),
              title: Text("warning".tr),
              content: Text("no_font_file_tip".tr),
              actions: [TextButton(onPressed: Get.back, child: Text("confirm".tr))],
            ),
          );
        }
      }
    } else {
      isFontFileAvailable.value = false;
    }
  }

  void getBgImage() {
    if (Get.context!.isDarkMode) {
      currentBgImagePath.value = LocalStorageService.instance.getReaderNightBgImage();
    } else {
      currentBgImagePath.value = LocalStorageService.instance.getReaderDayBgImage();
    }
  }

  Future<bool?> pickBgImageFile(bool isDark) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg']);
      if (result == null) return null; // 用户取消

      final tempPath = result.files.single.path!;

      await deleteBgImageDir();

      final srcFile = File(tempPath);
      final ext = path.extension(tempPath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = isDark ? "night_$timestamp$ext" : "day_$timestamp$ext";
      final appDir = await getApplicationSupportDirectory();
      final destDir = Directory('${appDir.path}/bgImage');
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }
      final destPath = '${destDir.path}/$fileName';
      await srcFile.copy(destPath);

      if (isDark) {
        changeReaderNightBgImage(destPath);
      } else {
        changeReaderDayBgImage(destPath);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteBgImageDir() async {
    final appDir = await getApplicationSupportDirectory();
    final fontsDir = Directory('${appDir.path}/bgImage');

    if (await fontsDir.exists()) {
      await fontsDir.delete(recursive: true);
    }
  }
}

///查找目标字符串在二维列表中出现的位置
///返回格式：[外层索引, 内层索引]，未找到则返回 null
List<int>? _findIndexPositionInCatalogue(Map<String, dynamic> args) {
  final catalogue = args['catalogue'] as List<List<String>>;
  final targetCid = args['cid'] as String;

  // 遍历外层列表，同时获取索引和子列表
  for (int outerIndex = 0; outerIndex < catalogue.length; outerIndex++) {
    List<String> innerList = catalogue[outerIndex];
    // 查找目标字符串在当前子列表中的索引
    int innerIndex = innerList.indexOf(targetCid);
    // 如果找到（索引不为 -1），返回位置
    if (innerIndex != -1) {
      return [outerIndex, innerIndex];
      // return IndexPosition(volumeIndex: outerIndex, chapterIndex: innerIndex);
    }
  }
  return null;
}

class ReaderSettingsState {
  final ReaderDirection direction;
  final bool pageTurningAnimation;
  final bool wakeLock;
  final DualPageMode dualPageMode;
  final double dualPageSpacing;
  final bool immersionMode;
  final bool showStatusBar;
  final double fontSize;
  final double lineSpacing;
  final double leftMargin;
  final double topMargin;
  final double rightMargin;
  final double bottomMargin;
  final Color? textColor;
  final Color? bgColor;
  final String? textStyleFilePath;
  final String? textFamily;
  final String? bgImagePath;
  final String? readerDayBgImage;
  final String? readerNightBgImage;
  final Color? readerDayTextColor;
  final Color? readerNightTextColor;
  final Color? readerDayBgColor;
  final Color? readerNightBgColor;

  ReaderSettingsState({
    required this.direction,
    required this.pageTurningAnimation,
    required this.wakeLock,
    required this.dualPageMode,
    required this.dualPageSpacing,
    required this.immersionMode,
    required this.showStatusBar,
    required this.fontSize,
    required this.lineSpacing,
    required this.leftMargin,
    required this.topMargin,
    required this.rightMargin,
    required this.bottomMargin,
    required this.textColor,
    required this.bgColor,
    required this.textStyleFilePath,
    required this.textFamily,
    required this.bgImagePath,
    required this.readerDayBgImage,
    required this.readerNightBgImage,
    required this.readerDayTextColor,
    required this.readerNightTextColor,
    required this.readerDayBgColor,
    required this.readerNightBgColor,
  });

  ReaderSettingsState copyWith({
    ReaderDirection? direction,
    bool? pageTurningAnimation,
    bool? wakeLock,
    DualPageMode? dualPageMode,
    double? dualPageSpacing,
    bool? immersionMode,
    bool? showStatusBar,
    double? fontSize,
    double? lineSpacing,
    double? leftMargin,
    double? topMargin,
    double? rightMargin,
    double? bottomMargin,
    Color? textColor,
    Color? bgColor,
    String? textStyleFilePath,
    String? textFamily,
    String? bgImagePath,
    String? readerDayBgImage,
    String? readerNightBgImage,
    Color? readerDayTextColor,
    Color? readerNightTextColor,
    Color? readerDayBgColor,
    Color? readerNightBgColor,
  }) => ReaderSettingsState(
    direction: direction ?? this.direction,
    pageTurningAnimation: pageTurningAnimation ?? this.pageTurningAnimation,
    wakeLock: wakeLock ?? this.wakeLock,
    dualPageMode: dualPageMode ?? this.dualPageMode,
    dualPageSpacing: dualPageSpacing ?? this.dualPageSpacing,
    immersionMode: immersionMode ?? this.immersionMode,
    showStatusBar: showStatusBar ?? this.showStatusBar,
    fontSize: fontSize ?? this.fontSize,
    lineSpacing: lineSpacing ?? this.lineSpacing,
    leftMargin: leftMargin ?? this.leftMargin,
    topMargin: topMargin ?? this.topMargin,
    rightMargin: rightMargin ?? this.rightMargin,
    bottomMargin: bottomMargin ?? this.bottomMargin,
    textColor: textColor ?? this.textColor,
    bgColor: bgColor ?? this.bgColor,
    textStyleFilePath: textStyleFilePath ?? this.textStyleFilePath,
    textFamily: textFamily ?? this.textFamily,
    bgImagePath: bgImagePath ?? this.bgImagePath,
    readerDayBgImage: readerDayBgImage ?? this.readerDayBgImage,
    readerNightBgImage: readerNightBgImage ?? this.readerNightBgImage,
    readerDayTextColor: readerDayTextColor ?? this.readerDayTextColor,
    readerNightTextColor: readerNightTextColor ?? this.readerNightTextColor,
    readerDayBgColor: readerDayBgColor ?? this.readerDayBgColor,
    readerNightBgColor: readerNightBgColor ?? this.readerNightBgColor,
  );

  ReaderSettingsState.init()
    : direction = LocalStorageService.instance.getReaderDirection(),
      pageTurningAnimation = LocalStorageService.instance.getReaderPageTurningAnimation(),
      wakeLock = LocalStorageService.instance.getReaderWakeLock(),
      dualPageMode = LocalStorageService.instance.getReaderDualPageMode(),
      dualPageSpacing = LocalStorageService.instance.getReaderDualPageSpacing(),
      immersionMode = LocalStorageService.instance.getReaderImmersionMode(),
      showStatusBar = LocalStorageService.instance.getReaderStatusBar(),
      fontSize = LocalStorageService.instance.getReaderFontSize(),
      lineSpacing = LocalStorageService.instance.getReaderLineSpacing(),
      leftMargin = LocalStorageService.instance.getReaderLeftMargin(),
      topMargin = LocalStorageService.instance.getReaderTopMargin(),
      rightMargin = LocalStorageService.instance.getReaderRightMargin(),
      bottomMargin = LocalStorageService.instance.getReaderBottomMargin(),
      textColor = LocalStorageService.instance.getReaderDayTextColor(),
      bgColor = LocalStorageService.instance.getReaderDayBgColor(),
      textStyleFilePath = LocalStorageService.instance.getReaderTextStyleFilePath(),
      textFamily = LocalStorageService.instance.getReaderTextFamily(),
      bgImagePath = LocalStorageService.instance.getReaderDayBgImage(),
      readerDayBgImage = LocalStorageService.instance.getReaderDayBgImage(),
      readerNightBgImage = LocalStorageService.instance.getReaderNightBgImage(),
      readerDayTextColor = LocalStorageService.instance.getReaderDayTextColor(),
      readerNightTextColor = LocalStorageService.instance.getReaderNightTextColor(),
      readerDayBgColor = LocalStorageService.instance.getReaderDayBgColor(),
      readerNightBgColor = LocalStorageService.instance.getReaderNightBgColor();
}
