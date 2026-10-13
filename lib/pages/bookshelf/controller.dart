import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/bookshelf.dart';
import 'package:hikari_novel_flutter/models/custom_exception.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/service/api_service.dart';
import 'package:hikari_novel_flutter/parser/parser.dart';
import 'package:hikari_novel_flutter/pages/main/controller.dart';

import '../../common/database/database.dart';
import '../../service/db_service.dart';

class BookshelfController extends GetxController with GetTickerProviderStateMixin {
  RxInt tabIndex = 0.obs; //保存tab索引位置

  Rx<PageState> pageState = Rx(PageState.bookshelfContent);

  late TabController tabController;
  final List tabs = ["0", "1", "2", "3", "4", "5"];

  RxBool isSelectionMode = false.obs;

  final Set<int> _loadedClassIds = {};
  final Set<int> _loadingClassIds = {};
  String? _lastLoadError;

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this, initialIndex: tabIndex.value);
    tabController.addListener(_onTabChanged);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loadClass(tabController.index);
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    tabIndex.value = tabController.index;
    loadClass(tabController.index);
  }

  Future<void> refreshDefaultBookshelf() async {
    await loadClass(0, force: true);
  }

  Future<String> refreshBookshelf() async {
    final ok = await loadClass(tabController.index, force: true);
    if (ok) return "update_successfully".tr;
    final err = _lastLoadError ?? "";
    if (err.contains(cloudflare429ExceptionMessage)) return "cloudflare_429_exception_tip".tr;
    return "update_failed".tr;
  }

  /// 只拉当前分类。force 为 true 时忽略已加载标记再拉一次。成功后才替换本地缓存。
  Future<bool> loadClass(int index, {bool force = false}) async {
    if (force) {
      _loadedClassIds.remove(index);
    } else if (_loadedClassIds.contains(index)) {
      return true;
    }
    if (_loadingClassIds.contains(index)) return !force;
    _loadingClassIds.add(index);
    try {
      final ok = await _insertAll(index);
      if (ok) _loadedClassIds.add(index);
      return ok;
    } finally {
      _loadingClassIds.remove(index);
    }
  }

  Future<bool> _insertAll(int index) async {
    _setFetching(index, true);
    try {
      final result = await ApiService.instance.getBookshelf(classId: index);
      switch (result) {
        case Success():
          _setFetching(index, false);
          _publishError(index, null);
          await DBService.instance.deleteBookshelfByClassId(index.toString());
          final bookshelf = Parser.getBookshelf(result.data, index);
          if (bookshelf.list.isNotEmpty) {
            final insertData = bookshelf.list.map((e) {
              return BookshelfEntityData(aid: e.aid, bid: e.bid, url: e.url, title: e.title, img: e.img, classId: bookshelf.classId.toString());
            });
            await DBService.instance.insertAllBookshelf(insertData);
          }
          return true;
        case Error():
          _setFetching(index, false);
          _publishError(index, "${result.error}");
          return false;
      }
    } finally {
      _setFetching(index, false);
    }
  }

  void _setFetching(int index, bool fetching) {
    final content = _content(index);
    if (content == null) return;
    content.fetching.value = fetching;
    if (fetching && (content.bookshelf.value == null || content.bookshelf.value!.list.isEmpty)) {
      content.pageState.value = PageState.loading;
    }
  }

  BookshelfContentController? _content(int index) {
    final tag = "BookshelfContentController $index";
    if (!Get.isRegistered<BookshelfContentController>(tag: tag)) return null;
    return Get.find<BookshelfContentController>(tag: tag);
  }

  void _publishError(int index, String? error) {
    _lastLoadError = error;
    final content = _content(index);
    if (content == null) return;
    if (error == null) {
      content.clearLoadError();
    } else {
      content.showLoadError(error);
    }
  }
}

class BookshelfContentController extends GetxController {
  final String classId;

  BookshelfContentController({required this.classId});

  final BookshelfController _bookshelfController = Get.find();
  final MainController _mainController = Get.find();

  bool get isSelectionMode => _bookshelfController.isSelectionMode.value;

  Rxn<Bookshelf> bookshelf = Rxn();
  Rx<PageState> pageState = Rx(PageState.loading);
  final loadError = RxnString();
  final fetching = false.obs;

  @override
  void onReady() {
    super.onReady();

    DBService.instance.getBookshelfByClassId(classId).listen((bss) async {
      List<BookshelfNovelInfo> list = bss.map((i) => BookshelfNovelInfo(bid: i.bid, aid: i.aid, url: i.url, title: i.title, img: i.img)).toList();

      if (list.isEmpty) {
        bookshelf.value = null;
        if (loadError.value != null) {
          pageState.value = PageState.error;
        } else if (!fetching.value) {
          pageState.value = PageState.empty;
        }
      } else {
        bookshelf.value = Bookshelf(list: list, classId: classId);
        pageState.value = PageState.success;
      }
    });
  }

  void showLoadError(String message) {
    loadError.value = message;
    if (bookshelf.value == null || bookshelf.value!.list.isEmpty) {
      pageState.value = PageState.error;
    }
  }

  void clearLoadError() {
    loadError.value = null;
  }

  Future<void> retry() => _bookshelfController.loadClass(int.parse(classId), force: true);

  void toggleCoverSelection(String aid) {
    final selected = bookshelf.value!.list.firstWhere((v) => v.aid == aid).isSelected.value;
    bookshelf.value!.list.firstWhere((v) => v.aid == aid).isSelected.value = !selected;
  }

  Future removeNovelFromList() => ApiService.instance.removeNovelFromList(list: getSelectedNovel(), classId: int.parse(classId));

  Future moveNovelToOther(int newClassId) => ApiService.instance.moveNovelToOther(list: getSelectedNovel(), classId: int.parse(classId), newClassId: newClassId);

  List<String> getSelectedNovel() => bookshelf.value!.list.where((v) => v.isSelected.value == true).map((i) => i.bid).toList();

  void exitSelectionMode() {
    _bookshelfController.isSelectionMode.value = false;
    _mainController.showBookshelfBottomActionBar.value = false;
    deselect();
  }

  void enterSelectionMode() {
    _bookshelfController.isSelectionMode.value = true;
    _mainController.showBookshelfBottomActionBar.value = true;
  }

  void deselect() {
    for (final v in bookshelf.value!.list) {
      v.isSelected.value = false;
    }
  }

  void selectAll() {
    for (final v in bookshelf.value!.list) {
      v.isSelected.value = true;
    }
  }
}

class BookshelfSearchController extends GetxController {
  final _bookshelfController = Get.find<BookshelfController>();
  final searchTextEditController = Get.find<TextEditingController>(tag: "searchTextEditController");

  RxList<BookshelfNovelInfo> data = RxList();
  Rx<PageState> pageState = Rx(PageState.placeholder);

  void getBookshelfByKeyword() async {
    data.assignAll(
      (await DBService.instance.getBookshelfByKeyword(
        searchTextEditController.text,
      )).map((e) => BookshelfNovelInfo(bid: e.bid, aid: e.aid, url: e.url, title: e.title, img: e.img)),
    );
    if (data.isEmpty) {
      pageState.value = PageState.empty;
    } else {
      pageState.value = PageState.success;
    }
  }

  void back() => _bookshelfController.pageState.value = PageState.bookshelfContent;
}
