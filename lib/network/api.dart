import 'dart:ui';

import 'package:enough_convert/enough_convert.dart';
import 'package:get/get.dart' hide Response;
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/models/common/charsets_type.dart';
import 'package:hikari_novel_flutter/models/common/language.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/network/request.dart';

import '../service/local_storage_service.dart';

class Api {
  static Language get _language => LocalStorageService.instance.getLanguage();

  static CharsetsType get charsetsType {
    if (_language == Language.followSystem) {
      if (Get.deviceLocale == Locale("zh", "CN")) {
        return CharsetsType.gbk;
      } else if (Get.deviceLocale == Locale("zh", "TW")) {
        return CharsetsType.big5Hkscs;
      } else {
        return CharsetsType.gbk;
      }
    }
    return switch (_language) {
      Language.simplifiedChinese => CharsetsType.gbk,
      Language.traditionalChinese => CharsetsType.big5Hkscs,
      _ => CharsetsType.gbk,
    };
  }

  static Wenku8Node get wenku8Node => LocalStorageService.instance.getWenku8Node();

  static String latestUrl = "https://api.github.com/repos/15dd/hikari_novel_flutter/releases/latest";

  /// 根据排名获取小说列表
  /// - [ranking] 排行榜种类
  /// - [index] 第几页
  static Future<Resource> getNovelByRanking({required String ranking, required int index}) {
    final String url = "${wenku8Node.node}/modules/article/toplist.php?sort=$ranking&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 根据分类获取小说列表
  /// - [category] 小说的分类，即tag
  /// - [sort] 按什么排序
  /// - [index] 第几页
  static Future<Resource> getNovelByCategory({required String category, required String sort, required int index}) {
    switch (charsetsType) {
      case CharsetsType.gbk:
        {
          category = GbkCodec().encode(category).map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join().trim();
        }
      case CharsetsType.big5Hkscs:
        {
          category = Big5Codec().encode(category).map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join().trim();
        }
    }
    String url = "${wenku8Node.node}/modules/article/tags.php?t=$category&v=$sort&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取小说信息
  /// - [aid] 小说的id
  static Future<Resource> getNovelDetail({required String aid}) {
    final String url = "${wenku8Node.node}/modules/article/articleinfo.php?id=$aid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取小说的章节目录
  /// - [aid] 小说的id
  static Future<Resource> getCatalogue({required String aid}) {
    final String url = "${wenku8Node.node}/modules/article/reader.php?aid=$aid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 加入书库
  /// - [aid] 小说的id
  static Future<Resource> addNovel({required String aid}) {
    final String url = "${wenku8Node.node}/modules/article/addbookcase.php?bid=$aid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 移出书库
  /// - [delid] 该书在书架中的id，即bid
  static Future<Resource> removeNovel({required String delid}) {
    final String url = "${wenku8Node.node}/modules/article/bookcase.php?delid=$delid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 从列表移出书库
  /// - [list] 要删除的书籍列表
  /// - [classId] 要将这些书从哪个书架中删除
  static Future<Resource> removeNovelFromList({required List<String> list, required int classId}) {
    final String url = "${wenku8Node.node}/modules/article/bookcase.php";
    final Map<String, dynamic> params = {"checkid[]": list, "classlist": classId, "checkall": "checkall", "newclassid": -1, "classid": classId};
    return Request.postForm(url, data: params, charsetsType: charsetsType);
  }

  /// 移动到其它书架
  /// - [list] 要移动的书籍列表
  /// - [classId] 要将这些书从哪个书架中移出
  /// - [newClassId] 要将这些书移动到那个书架中
  static Future<Resource> moveNovelToOther({required List<String> list, required int classId, required int newClassId}) {
    final String url = "${wenku8Node.node}/modules/article/bookcase.php";
    final Map<String, dynamic> params = {"checkid[]": list, "classlist": classId, "checkall": "checkall", "newclassid": newClassId, "classid": classId};
    return Request.postForm(url, data: params, charsetsType: charsetsType);
  }

  /// 获取书架
  /// - [classId] 要获取的书架编号
  static Future<Resource> getBookshelf({required int classId}) {
    final String url = "${wenku8Node.node}/modules/article/bookcase.php?classid=$classId";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取其它用户收藏的书籍
  /// - [uid] 该用户的id
  static Future<Resource> getBookshelfFromUser({required String uid}) {
    final String url = "${wenku8Node.node}/userpage.php?uid=$uid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取评论区
  /// - [aid] 该评论区所属的书籍的id
  /// - [index] 第几页
  static Future<Resource> getComment({required String aid, required int index}) {
    final String url = "${wenku8Node.node}/modules/article/reviews.php?aid=$aid&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取回复
  /// - [rid] 该回复的id
  /// - [index] 第几页
  static Future<Resource> getReply({required String rid, required int index}) {
    final String url = "${wenku8Node.node}/modules/article/reviewshow.php?rid=$rid&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取推荐页
  static Future<Resource> getRecommend() {
    final String url = "${wenku8Node.node}/index.php";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 为小说投票
  /// - [aid] 被投票的小说的id
  static Future<Resource> novelVote({required String aid}) {
    final String url = "${wenku8Node.node}/modules/article/uservote.php?id=$aid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 根据标题搜索小说
  /// - [title] 标题关键字
  /// - [index] 第几页
  static Future<Resource> searchNovelByTitle({required String title, required int index}) {
    switch (charsetsType) {
      //url编码
      case CharsetsType.gbk:
        title = GbkEncoder().convert(title).map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
      case CharsetsType.big5Hkscs:
        title = Big5Encoder().convert(title).map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
    }
    final String url = "${wenku8Node.node}/modules/article/search.php?searchtype=articlename&searchkey=$title&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 根据作者搜索小说
  /// - [author] 作者关键字
  /// - [index] 第几页
  static Future<Resource> searchNovelByAuthor({required String author, required int index}) {
    switch (charsetsType) {
      //url编码
      case CharsetsType.gbk:
        author = GbkEncoder().convert(author).map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
      case CharsetsType.big5Hkscs:
        author = Big5Encoder().convert(author).map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
    }
    final String url = "${wenku8Node.node}/modules/article/search.php?searchtype=author&searchkey=$author&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取用户信息
  static Future<Resource> getUserInfo() {
    final String url = "${wenku8Node.node}/userdetail.php";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取已完结小说的列表
  /// - [index] 第几页
  static Future<Resource> getCompletionNovel({required int index}) {
    final String url = "${wenku8Node.node}/modules/article/articlelist.php?fullflag=1&page=$index";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 发表书评
  /// - [aid] 书号
  /// - [title] 书评的标题
  /// - [content] 书评的内容
  static Future<Resource> sendComment({required String aid, required String title, required String content}) {
    final String url = "${wenku8Node.node}/modules/article/reviews.php?aid=$aid";

    String submit;
    switch (charsetsType) {
      case CharsetsType.gbk:
        submit = GbkEncoder().convert("发表书评").map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
        title = title.gbkUrlEncodingIfNotAscii();
        content = content.gbkUrlEncodingIfNotAscii();
      case CharsetsType.big5Hkscs:
        submit = Big5Encoder().convert("發表書評").map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
        title = title.big5UrlEncodingIfNotAscii();
        content = content.big5UrlEncodingIfNotAscii();
    }
    //加上url编码的空格，即"+"
    submit = "+$submit+";

    final String params = "ptitle=$title&pcontent=$content&Submit=$submit";
    return Request.postForm(url, data: params, charsetsType: charsetsType);
  }

  /// 发表回复
  /// - [aid] 书号
  /// - [rid] 要回复的书评id
  /// - [content] 回复的内容
  static Future<Resource> sendReply({required String aid, required String rid, required String content}) {
    final String url = "${wenku8Node.node}/modules/article/reviewshow.php?rid=$rid&aid=$aid";

    String submit;
    switch (charsetsType) {
      case CharsetsType.gbk:
        submit = GbkEncoder().convert("发表书评").map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
        content = content.gbkUrlEncodingIfNotAscii();
      case CharsetsType.big5Hkscs:
        submit = Big5Encoder().convert("發表書評").map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join();
        content = content.big5UrlEncodingIfNotAscii();
    }
    //加上url编码的空格，即"+"
    submit = "+$submit+";

    final String params = "pcontent=$content&Submit=$submit";

    return Request.postForm(url, data: params, charsetsType: charsetsType);
  }

  /// 获取小说章节内容
  /// - [aid] 小说id
  /// - [cid] 章节id
  static Future<Resource> getNovelContent({required String aid, required String cid}) {
    final String url = "${Api.wenku8Node.node}/modules/article/reader.php?aid=$aid&cid=$cid";
    return Request.get(url, charsetsType: charsetsType);
  }

  /// 获取Github上面的最新版本
  static Future<Resource> fetchLatestRelease() {
    return Request.getCommonData(latestUrl);
  }
}