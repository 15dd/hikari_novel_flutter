import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/novel_cover.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/network/parser.dart';

import '../../network/api.dart';

class UserBookshelfController extends GetxController {
  final String uid;
  final Rxn<List<NovelCover>> list = Rxn();
  final Rx<PageState> pageState = Rx(PageState.loading);
  String errorMsg = "";

  UserBookshelfController({required this.uid});

  @override
  void onReady() {
    super.onReady();
    getPage();
  }

  void getPage() async {
    final data = await Api.getBookshelfFromUser(uid: uid);
    switch (data) {
      case Success():
        {
          list.value = Parser.parseOtherBookshelfToList(data.data);
          pageState.value = PageState.success;
        }
      case Error():
        {
          errorMsg = data.error;
          pageState.value = PageState.error;
        }
    }
  }
}