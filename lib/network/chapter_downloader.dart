import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:path_provider/path_provider.dart';
import 'api.dart';

import '../models/common/charsets_type.dart';
import '../models/common/wenku8_node.dart';
import '../service/local_storage_service.dart';
import 'request.dart';

class ChapterDownloader {
  final Map<String, CancelToken> _cancelTokens = {}; // taskId -> CancelToken

  void cancel(String taskId) {
    final token = _cancelTokens[taskId];
    if (token != null && !token.isCancelled) token.cancel('canceled');
    _cancelTokens.remove(taskId);
  }

  void clearCancel(String taskId) {
    _cancelTokens.remove(taskId);
  }

  // bool _isCanceled(String taskId) => _cancelTokens[taskId]?.isCancelled ?? false;

  /// 使用 POST 获取流并保存到 app documents 目录，返回本地路径
  Future<String> download({required String taskId, required String aid, required String cid}) async {
    final dir = await getApplicationSupportDirectory();
    final cacheDir = Directory("${dir.path}/cached_chapter");
    if (!(await cacheDir.exists())) {
      await cacheDir.create(recursive: true);
    }

    final savePath = "${cacheDir.path}/${aid}_$cid.txt";
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    try {
      // 网络请求（支持 CancelToken）
      final content = await _fetchChapterContent(aid: aid, cid: cid, cancelToken: cancelToken);

      // 写文件
      try {
        final file = File(savePath);
        await file.writeAsString(content);
      } catch (ioe) {
        // 文件写入失败
        final file = File(savePath);
        if (await file.exists()) await file.delete();
        rethrow;
      }

      _cancelTokens.remove(taskId);
      return savePath;
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  Future<String> _fetchChapterContent({required String aid, required String cid, required CancelToken cancelToken}) async {
    // 拼接章节 URL，并加上 charset 参数（与 Request.get 逻辑保持一致）
    String url = "${Api.wenku8Node.node}/modules/article/reader.php?aid=$aid&cid=$cid";
    final CharsetsType cs = Api.charsetsType;
    switch (cs) {
      case CharsetsType.gbk:
        url += "&charset=gbk";
      case CharsetsType.big5Hkscs:
        url += "&charset=big5";
    }

    final cookie = LocalStorageService.instance.getCookie();

    Response<dynamic> response;
    try {
      response = await Request.dio.get(
        url,
        cancelToken: cancelToken,
        options: cookie != null ? Options(headers: {...Request.dio.options.headers, 'Cookie': cookie}) : null,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) throw Exception('canceled');
      rethrow;
    }

    // 手动处理 3xx 跳转（与 Request.get 的重定向处理思路一致）
    if (response.statusCode != null && response.statusCode! >= 300 && response.statusCode! < 400) {
      final location = response.headers.value('location');
      if (location != null) {
        final redirectedUrl = location.startsWith('http') ? location : "${Api.wenku8Node.node}/$location";
        response = await Request.dio.get(
          redirectedUrl,
          cancelToken: cancelToken,
          options: cookie != null ? Options(headers: {...Request.dio.options.headers, 'Cookie': cookie}) : null,
        );
      }
    }

    if (cancelToken.isCancelled) throw Exception('canceled');

    final Uint8List bytes = response.data is Uint8List ? response.data as Uint8List : Uint8List.fromList((response.data as List<int>).cast<int>());

    switch (cs) {
      case CharsetsType.gbk:
        return GbkDecoder().convert(bytes);
      case CharsetsType.big5Hkscs:
        return Big5Decoder().convert(bytes);
    }
  }
}
