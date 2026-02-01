import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/bookshelf.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/network/api.dart';
import 'package:hikari_novel_flutter/network/parser.dart';
import 'package:hikari_novel_flutter/pages/main/controller.dart';

import '../../common/database/database.dart';
import '../../service/db_service.dart';

class BookshelfController extends GetxController with GetTickerProviderStateMixin {
  RxInt tabIndex = 0.obs; //保存tab索引位置

  Rx<PageState> pageState = Rx(PageState.bookshelfContent);

  late TabController tabController;
  final List tabs = ["0", "1", "2", "3", "4", "5"];

  RxBool isSelectionMode = false.obs;

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this, initialIndex: tabIndex.value);
    super.onInit();
  }

  Future<void> refreshDefaultBookshelf() async {
    await DBService.instance.deleteDefaultBookshelf();
    await _insertAll(0);
  }

  Future<String> refreshBookshelf() async {
    await DBService.instance.deleteAllBookshelf();

    final futures = Iterable.generate(6, (index) async {
      final result = await _insertAll(index);
      if (!result) return "update_failed".tr;
    });
    await Future.wait(futures);
    return "update_successfully".tr;
  }

  Future<bool> _insertAll(int index) async {
    final result = await Api.getBookshelf(classId: index);
    switch (result) {
      case Success():
        {
          final bookshelf = Parser.getBookshelf(result.data, index);
          if (bookshelf.list.isNotEmpty) {
            final insertData = bookshelf.list.map((e) {
              return BookshelfEntityData(aid: e.aid, bid: e.bid, url: e.url, title: e.title, img: e.img, classId: bookshelf.classId.toString());
            });
            await DBService.instance.insertAllBookshelf(insertData);
          }
          return true;
        }
      case Error():
        {
          return false;
        }
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
  String errorMsg = "";

  @override
  void onReady() {
    super.onReady();

    DBService.instance.getBookshelfByClassId(classId).listen((bss) async {
      List<BookshelfNovelInfo> list = bss.map((i) => BookshelfNovelInfo(bid: i.bid, aid: i.aid, url: i.url, title: i.title, img: i.img)).toList();

      if (list.isEmpty) {
        bookshelf.value = null;
        pageState.value = PageState.empty;
      } else {
        bookshelf.value = Bookshelf(list: list, classId: classId);
        pageState.value = PageState.success;
      }
    });
  }

  void toggleCoverSelection(String aid) {
    final selected = bookshelf.value!.list.firstWhere((v) => v.aid == aid).isSelected.value;
    bookshelf.value!.list.firstWhere((v) => v.aid == aid).isSelected.value = !selected;
  }

  Future removeNovelFromList() => Api.removeNovelFromList(list: getSelectedNovel(), classId: int.parse(classId));

  Future moveNovelToOther(int newClassId) =>
    Api.moveNovelToOther(list: getSelectedNovel(), classId: int.parse(classId), newClassId: newClassId);


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
