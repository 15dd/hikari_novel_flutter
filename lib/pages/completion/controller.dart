import 'package:get/get.dart';
import 'package:hikari_novel_flutter/base/base_list_page_controller.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';

import '../../models/novel_cover.dart';
import '../../models/resource.dart';
import '../../network/api.dart';
import '../../network/parser.dart';

class CompletionController extends BaseListPageController<NovelCover> {
  @override
  Rx<PageState> pageState = Rx(PageState.loading);

  @override
  Future<Resource> getData(int index) {
    return Api.getCompletionNovel(index: index);
  }

  @override
  List<NovelCover> getParser(String html) {
    return Parser.parseToList(html);
  }
}
