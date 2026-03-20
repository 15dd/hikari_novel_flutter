import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/base/base_list_page_controller.dart';
import 'package:hikari_novel_flutter/models/comment_item.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/network/api.dart';
import 'package:hikari_novel_flutter/network/parser.dart';

class CommentController extends BaseListPageController<CommentItem> with GetSingleTickerProviderStateMixin {
  final String aid;

  CommentController({required this.aid});

  final commentTitleController = TextEditingController();
  final commentContentController = TextEditingController();

  @override
  Rx<PageState> pageState = Rx(PageState.loading);

  @override
  List<CommentItem> getParser(String html) => Parser.getComment(html);

  @override
  Future<Resource> getData(int index) => Api.getComment(aid: aid, index: index);

  bool _isFabVisible = true;
  late final AnimationController _fabAnimationCtr;
  late final Animation<Offset> animation;

  @override
  void onInit() {
    super.onInit();
    _fabAnimationCtr = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..forward();
    animation = _fabAnimationCtr.drive(Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)));
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

  Future<String> sendComment() async {
    if (commentTitleController.text.isEmpty || commentContentController.text.isEmpty) {
      return "send_comment_tip".tr;
    }

    if (commentContentController.text.length < 7) {
      return "send_comment_tip_2".tr;
    }

    final result = await Api.sendComment(aid: aid, title: commentTitleController.text, content: commentContentController.text);
    commentContentController.clear();
    switch (result) {
      case Success():
        {
          if (Parser.isError(result.data)) {
            return "send_failed".tr;
          } else {
            return "send_successfully".tr;
          }
        }
      case Error():
        {
          return "network_error".tr;
        }
    }
  }
}
