import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:get/get.dart' hide Response;
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/models/common/charset_type.dart';
import 'package:hikari_novel_flutter/models/common/language.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/custom_exception.dart';
import 'package:hikari_novel_flutter/models/resource.dart';

import '../common/log.dart';
import '../src/rust/api.dart';
import 'local_storage_service.dart';

class ApiService extends GetxService {
  static ApiService get instance => Get.find<ApiService>();

  Wenku8Node get wenku8Node => LocalStorageService.instance.getWenku8Node();

  final _Wenku8Http _client = _Wenku8Http();

  Future<void> initCookie() async {
    await _client.importStored();
  }

  void deleteCookie() {
    unawaited(clearCookies());
  }

  Language get _language => LocalStorageService.instance.getLanguage();

  CharsetType get charsetType {
    if (_language == Language.followSystem) {
      if (Get.deviceLocale == Locale("zh", "CN")) {
        return CharsetType.gbk;
      } else if (Get.deviceLocale == Locale("zh", "TW")) {
        return CharsetType.big5Hkscs;
      } else {
        return CharsetType.gbk;
      }
    }
    return switch (_language) {
      Language.simplifiedChinese => CharsetType.gbk,
      Language.traditionalChinese => CharsetType.big5Hkscs,
      _ => CharsetType.gbk,
    };
  }

  /// 根据排名获取小说列表
  /// - [ranking] 排行榜种类
  /// - [index] 第几页
  Future<Resource> getNovelByRanking({
    required String ranking,
    required int index,
  }) {
    final String url =
        "${wenku8Node.node}/modules/article/toplist.php?sort=$ranking&page=$index";
    return _client.get(url, charsetType: charsetType, appendCharset: false);
  }

  /// 根据分类获取小说列表
  /// - [category] 小说的分类，即tag
  /// - [sort] 按什么排序
  /// - [index] 第几页
  Future<Resource> getNovelByCategory({
    required String category,
    required String sort,
    required int index,
  }) {
    switch (charsetType) {
      case CharsetType.gbk:
        {
          category = GbkCodec()
              .encode(category)
              .map(
                (b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}',
              )
              .join()
              .trim();
        }
      case CharsetType.big5Hkscs:
        {
          category = Big5Codec()
              .encode(category)
              .map(
                (b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}',
              )
              .join()
              .trim();
        }
    }
    String url =
        "${wenku8Node.node}/modules/article/tags.php?t=$category&v=$sort&page=$index";
    return _client.get(url, charsetType: charsetType);
  }

  /// 获取小说信息
  /// - [aid] 小说的id
  Future<Resource> getNovelDetail({required String aid}) {
    final String url =
        "${wenku8Node.node}/modules/article/articleinfo.php?id=$aid";
    return _client.get(url, charsetType: charsetType, appendCharset: false);
  }

  /// 获取小说的章节目录
  /// - [aid] 小说的id
  Future<Resource> getCatalogue({required String aid}) {
    final node = wenku8Node.node;
    final String url = "$node/modules/article/reader.php?aid=$aid";
    return _client.get(
      url,
      charsetType: charsetType,
      appendCharset: false,
      headers: [HttpHeader(name: "referer", value: "$node/book/$aid.htm")],
    );
  }

  /// 加入书库
  /// - [aid] 小说的id
  Future<Resource> addNovel({required String aid}) {
    final node = wenku8Node.node;
    final String url = "$node/modules/article/addbookcase.php?bid=$aid";
    return _client.get(
      url,
      charsetType: charsetType,
      followRedirects: false,
      headers: _shelfHeaders("$node/book/$aid.htm"),
      successOn302: true,
    );
  }

  /// 移出书库
  /// - [delid] 该书在书架中的id，即bid
  Future<Resource> removeNovel({required String delid}) {
    final node = wenku8Node.node;
    final String url = "$node/modules/article/bookcase.php?delid=$delid";
    return _client.get(
      url,
      charsetType: charsetType,
      followRedirects: false,
      headers: _shelfHeaders("$node/"),
      successOn302: true,
    );
  }

  /// 从列表移出书库
  /// - [list] 要删除的书籍列表
  /// - [classId] 要将这些书从哪个书架中删除
  Future<Resource> removeNovelFromList({
    required List<String> list,
    required int classId,
  }) {
    final String url = "${wenku8Node.node}/modules/article/bookcase.php";
    final Map<String, dynamic> params = {
      "checkid[]": list,
      "classlist": classId,
      "checkall": "checkall",
      "newclassid": -1,
      "classid": classId,
    };
    return _client.postForm(
      url,
      data: params,
      charsetType: charsetType,
      followRedirects: false,
      headers: _shelfHeaders("${wenku8Node.node}/"),
      successOn302: true,
    );
  }

  /// 移动到其它书架
  /// - [list] 要移动的书籍列表
  /// - [classId] 要将这些书从哪个书架中移出
  /// - [newClassId] 要将这些书移动到那个书架中
  Future<Resource> moveNovelToOther({
    required List<String> list,
    required int classId,
    required int newClassId,
  }) {
    final String url = "${wenku8Node.node}/modules/article/bookcase.php";
    final Map<String, dynamic> params = {
      "checkid[]": list,
      "classlist": classId,
      "checkall": "checkall",
      "newclassid": newClassId,
      "classid": classId,
    };
    return _client.postForm(
      url,
      data: params,
      charsetType: charsetType,
      followRedirects: false,
      headers: _shelfHeaders("${wenku8Node.node}/"),
      successOn302: true,
    );
  }

  /// 获取书架
  /// - [classId] 要获取的书架编号
  Future<Resource> getBookshelf({required int classId}) {
    final String url =
        "${wenku8Node.node}/modules/article/bookcase.php?classid=$classId";
    return _client.get(url, charsetType: charsetType, appendCharset: false);
  }

  /// 获取其它用户收藏的书籍
  /// - [uid] 该用户的id
  Future<Resource> getBookshelfFromUser({required String uid}) {
    final String url = "${wenku8Node.node}/userpage.php?uid=$uid";
    return _client.get(url, charsetType: charsetType);
  }

  /// 获取评论区
  /// - [aid] 该评论区所属的书籍的id
  /// - [index] 第几页
  Future<Resource> getComment({required String aid, required int index}) {
    final String url =
        "${wenku8Node.node}/modules/article/reviews.php?aid=$aid&page=$index";
    return _client.get(url, charsetType: charsetType);
  }

  /// 获取回复
  /// - [rid] 该回复的id
  /// - [index] 第几页
  Future<Resource> getReply({required String rid, required int index}) {
    final String url =
        "${wenku8Node.node}/modules/article/reviewshow.php?rid=$rid&page=$index";
    return _client.get(url, charsetType: charsetType);
  }

  /// 获取推荐页
  Future<Resource> getRecommend() {
    final String url = "${wenku8Node.node}/index.php";
    return _client.get(url, charsetType: charsetType);
  }

  /// 为小说投票
  /// - [aid] 被投票的小说的id
  Future<Resource> novelVote({required String aid}) {
    final String url =
        "${wenku8Node.node}/modules/article/uservote.php?id=$aid";
    return _client.get(url, charsetType: charsetType);
  }

  /// 根据标题搜索小说
  /// - [title] 标题关键字
  /// - [index] 第几页
  Future<Resource> searchNovelByTitle({
    required String title,
    required int index,
  }) {
    switch (charsetType) {
      //url编码
      case CharsetType.gbk:
        title = GbkEncoder()
            .convert(title)
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
      case CharsetType.big5Hkscs:
        title = Big5Encoder()
            .convert(title)
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
    }
    final String url =
        "${wenku8Node.node}/modules/article/search.php?searchtype=articlename&searchkey=$title&page=$index";
    return _client.get(url, charsetType: charsetType);
  }

  /// 根据作者搜索小说
  /// - [author] 作者关键字
  /// - [index] 第几页
  Future<Resource> searchNovelByAuthor({
    required String author,
    required int index,
  }) {
    switch (charsetType) {
      //url编码
      case CharsetType.gbk:
        author = GbkEncoder()
            .convert(author)
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
      case CharsetType.big5Hkscs:
        author = Big5Encoder()
            .convert(author)
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
    }
    final String url =
        "${wenku8Node.node}/modules/article/search.php?searchtype=author&searchkey=$author&page=$index";
    return _client.get(url, charsetType: charsetType);
  }

  /// 获取用户信息
  Future<Resource> getUserInfo() {
    final String url = "${wenku8Node.node}/userdetail.php";
    return _client.get(url, charsetType: charsetType);
  }

  /// 获取已完结小说的列表
  /// - [index] 第几页
  Future<Resource> getCompletionNovel({required int index}) {
    final String url =
        "${wenku8Node.node}/modules/article/articlelist.php?fullflag=1&page=$index";
    return _client.get(url, charsetType: charsetType);
  }

  /// 发表书评
  /// - [aid] 书号
  /// - [title] 书评的标题
  /// - [content] 书评的内容
  Future<Resource> sendComment({
    required String aid,
    required String title,
    required String content,
  }) {
    final String url =
        "${wenku8Node.node}/modules/article/reviews.php?aid=$aid";

    String submit;
    switch (charsetType) {
      case CharsetType.gbk:
        submit = GbkEncoder()
            .convert("发表书评")
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
        title = title.gbkUrlEncodingIfNotAscii();
        content = content.gbkUrlEncodingIfNotAscii();
      case CharsetType.big5Hkscs:
        submit = Big5Encoder()
            .convert("發表書評")
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
        title = title.big5UrlEncodingIfNotAscii();
        content = content.big5UrlEncodingIfNotAscii();
    }
    //加上url编码的空格，即"+"
    submit = "+$submit+";

    final String params = "ptitle=$title&pcontent=$content&Submit=$submit";
    return _client.postForm(url, data: params, charsetType: charsetType);
  }

  /// 发表回复
  /// - [aid] 书号
  /// - [rid] 要回复的书评id
  /// - [content] 回复的内容
  Future<Resource> sendReply({
    required String aid,
    required String rid,
    required String content,
  }) {
    final String url =
        "${wenku8Node.node}/modules/article/reviewshow.php?rid=$rid&aid=$aid";

    String submit;
    switch (charsetType) {
      case CharsetType.gbk:
        submit = GbkEncoder()
            .convert("发表书评")
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
        content = content.gbkUrlEncodingIfNotAscii();
      case CharsetType.big5Hkscs:
        submit = Big5Encoder()
            .convert("發表書評")
            .map((b) => '%${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
            .join();
        content = content.big5UrlEncodingIfNotAscii();
    }
    //加上url编码的空格，即"+"
    submit = "+$submit+";

    final String params = "pcontent=$content&Submit=$submit";

    return _client.postForm(url, data: params, charsetType: charsetType);
  }

  /// 获取小说章节内容
  /// - [aid] 小说id
  /// - [cid] 章节id
  Future<Resource> getNovelContent({required String aid, required String cid}) {
    final node = wenku8Node.node;
    final String url = "$node/modules/article/reader.php?aid=$aid&cid=$cid";
    return _client.get(
      url,
      charsetType: charsetType,
      appendCharset: false,
      headers: [
        HttpHeader(
          name: "referer",
          value: "$node/modules/article/reader.php?aid=$aid",
        ),
      ],
    );
  }

  /// 获取Github上面的最新版本
  Future<Resource> fetchLatestRelease() async {
    try {
      final response = await Dio(BaseOptions(headers: kUserAgent)).get(kLatestUrl);
      return Success(response.data);
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource> prepareLogin() => _client.prepareLogin();

  Future<Resource> fetchCheckcode() => _client.fetchCheckcode();

  Future<Resource> login({
    required String username,
    required String password,
    String? checkcode,
  }) {
    return _client.login(
      username: username,
      password: password,
      checkcode: checkcode,
    );
  }

  List<HttpHeader> _shelfHeaders(String referer) => [
    HttpHeader(name: "referer", value: referer),
    HttpHeader(name: "accept-language", value: "zh-CN,zh;q=0.9"),
  ];
}

class _Wenku8Http {
  static const _hosts = ["www.wenku8.net", "www.wenku8.cc"];

  Future<void> importStored() async {
    final localCookie = LocalStorageService.instance.getCookie();
    if (localCookie == null || localCookie.trim().isEmpty) return;
    final cookies = localCookie
        .split(";")
        .map((e) => e.trim())
        .where((e) => e.contains("="))
        .map((e) {
          final index = e.indexOf("=");
          return HttpHeader(
            name: e.substring(0, index),
            value: e.substring(index + 1),
          );
        })
        .toList();
    if (cookies.isEmpty) return;
    for (final host in _hosts) {
      await importCookies(domain: host, cookies: cookies);
    }
  }

  Future<void> _exportStored() async {
    final cookies = await exportCookies();
    if (cookies.isEmpty) return;
    final pairs = <String, String>{};
    for (final cookie in cookies) {
      pairs[cookie.name] = cookie.value;
    }
    if (pairs.isEmpty) return;
    LocalStorageService.instance.setCookie(
      pairs.entries.map((e) => "${e.key}=${e.value}").join(";"),
    );
  }

  Future<void> _prepare() async {
    await importStored();
  }

  /// 登录页打开时访问一次首页和登录页，返回登录页 HTML。
  Future<Resource> prepareLogin() async {
    try {
      await importStored();
      final node = LocalStorageService.instance.getWenku8Node().node;
      final home = await httpGet(url: "$node/", headers: const [], followRedirects: true);
      await _exportStored();
      final homeResource = _asResource("$node/", home, CharsetType.gbk);
      if (homeResource is Error) return homeResource;
      final loginUrl = "$node/login.php";
      final login = await httpGet(url: loginUrl, headers: const [], followRedirects: true);
      await _exportStored();
      return _asResource(loginUrl, login, CharsetType.gbk);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  List<HttpHeader> _loginReferer() {
    final node = LocalStorageService.instance.getWenku8Node().node;
    return [HttpHeader(name: "referer", value: "$node/login.php")];
  }

  Future<Resource> get(
    String url, {
    required CharsetType charsetType,
    bool followRedirects = true,
    List<HttpHeader> headers = const [],
    bool successOn302 = false,
    bool appendCharset = true,
  }) async {
    try {
      if (appendCharset) {
        final param = switch (charsetType) {
          CharsetType.gbk => "charset=gbk",
          CharsetType.big5Hkscs => "charset=big5",
        };
        url += url.contains("?") ? "&$param" : "?$param";
      }
      Log.d("$url ${charsetType.name}");
      await _prepare();
      final response = await httpGet(
        url: url,
        headers: headers,
        followRedirects: followRedirects,
      );
      await _exportStored();
      return _asResource(
        url,
        response,
        charsetType,
        successOn302: successOn302,
      );
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  Future<Resource> postForm(
    String url, {
    required Object? data,
    required CharsetType charsetType,
    bool followRedirects = true,
    List<HttpHeader> headers = const [],
    bool successOn302 = false,
  }) async {
    try {
      await _prepare();
      final encoded = data is String ? data : _encodeForm(data);
      final response = await httpPost(
        url: url,
        headers: [
          const HttpHeader(
            name: "content-type",
            value: "application/x-www-form-urlencoded",
          ),
          ...headers,
        ],
        body: utf8.encode(encoded),
        followRedirects: followRedirects,
      );
      await _exportStored();
      return _asResource(
        url,
        response,
        charsetType,
        successOn302: successOn302,
      );
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  Future<Resource> fetchCheckcode() async {
    try {
      await importStored();
      final node = LocalStorageService.instance.getWenku8Node().node;
      final url =
          "$node/checkcode.php?random=${DateTime.now().millisecondsSinceEpoch}";
      final response = await httpGet(
        url: url,
        headers: _loginReferer(),
        followRedirects: true,
      );
      await _exportStored();
      if (response.status == 429) return const Error(cloudflare429ExceptionMessage);
      final type = _header(response, "content-type");
      if (response.status == 200 && type.startsWith("image/")) {
        return Success(response.body);
      }
      return _asResource(url, response, CharsetType.gbk);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  Future<Resource> login({
    required String username,
    required String password,
    String? checkcode,
  }) async {
    try {
      await importStored();
      final url =
          "${LocalStorageService.instance.getWenku8Node().node}/login.php";
      final fields = [
        "username=${Uri.encodeQueryComponent(username)}",
        "password=${Uri.encodeQueryComponent(password)}",
        "usecookie=315360000",
        "action=login",
      ];
      if (checkcode != null && checkcode.isNotEmpty) {
        fields.add("checkcode=${Uri.encodeQueryComponent(checkcode)}");
      }
      final response = await httpPost(
        url: url,
        headers: [
          const HttpHeader(
            name: "content-type",
            value: "application/x-www-form-urlencoded",
          ),
          ..._loginReferer(),
        ],
        body: utf8.encode(fields.join("&")),
        followRedirects: false,
      );
      await _exportStored();
      if (response.status == 429) return const Error(cloudflare429ExceptionMessage);
      if (response.status == 403 || _isChallenge(response)) {
        return _asResource(url, response, CharsetType.gbk);
      }
      final text = GbkDecoder().convert(response.body);
      if (text.contains("登录成功") || text.contains("登錄成功")) {
        return const Success("");
      }
      return Error(text);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  Resource _asResource(
    String url,
    HttpResponse response,
    CharsetType charsetType, {
    bool successOn302 = false,
  }) {
    if (response.status == 302 && successOn302) return const Success("");
    if (response.status == 429) return const Error(cloudflare429ExceptionMessage);
    if (_isChallenge(response)) {
      throw CloudflareChallengeException(
        requestOptions: RequestOptions(path: url),
      );
    }
    if (response.status == 403) {
      final preview = utf8.decode(response.body, allowMalformed: true);
      final head = preview.length > 300 ? preview.substring(0, 300) : preview;
      if (head.contains("Just a moment") ||
          head.contains("__cf_chl_") ||
          head.contains("Attention Required")) {
        throw Cloudflare403Exception(requestOptions: RequestOptions(path: url));
      }
      return Error("403 $head");
    }
    final text = switch (charsetType) {
      CharsetType.gbk => GbkDecoder().convert(response.body),
      CharsetType.big5Hkscs => Big5Decoder().convert(response.body),
    };
    return Success(text);
  }

  bool _isChallenge(HttpResponse response) => response.headers.any(
    (header) =>
        header.name.toLowerCase() == "cf-mitigated" &&
        header.value.contains("challenge"),
  );

  String _header(HttpResponse response, String name) {
    for (final header in response.headers) {
      if (header.name.toLowerCase() == name) return header.value;
    }
    return "";
  }

  String _encodeForm(Object? data) {
    if (data is! Map) return "$data";
    final parts = <String>[];
    data.forEach((key, value) {
      final name = Uri.encodeQueryComponent("$key");
      if (value is List) {
        for (final item in value) {
          parts.add("$name=${Uri.encodeQueryComponent("$item")}");
        }
      } else {
        parts.add("$name=${Uri.encodeQueryComponent("$value")}");
      }
    });
    return parts.join("&");
  }
}
