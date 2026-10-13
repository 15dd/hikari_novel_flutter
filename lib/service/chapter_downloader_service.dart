import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:hikari_novel_flutter/service/api_service.dart';
import 'package:path_provider/path_provider.dart';

import '../common/log.dart';
import '../models/common/wenku8_node.dart';
import '../models/resource.dart';

class ChapterDownloaderService extends GetxService {
  // 存储取消令牌：taskId -> CancelToken
  final Map<String, CancelToken> _cancelTokens = {};

  // 存储下载状态：taskId -> bool (true=下载中)
  final Map<String, bool> _downloadingStatus = {};

  /// 取消指定任务的下载
  /// [taskId] 任务唯一标识
  void cancel(String taskId) {
    final token = _cancelTokens[taskId];
    if (token != null && !token.isCancelled) {
      try {
        token.cancel('用户主动取消下载');
        Log.i('任务 $taskId 已取消');
      } catch (e) {
        Log.e('取消任务 $taskId 失败: $e');
      }
    }
  }

  /// 清理指定任务的取消令牌（用于下载完成/失败后）
  void clearCancel(String taskId) {
    _cancelTokens.remove(taskId);
    _downloadingStatus.remove(taskId);
  }

  /// 检查任务是否正在下载
  bool isDownloading(String taskId) => _downloadingStatus[taskId] ?? false;

  /// 检查任务是否已取消
  bool isCanceled(String taskId) {
    final token = _cancelTokens[taskId];
    return token?.isCancelled ?? false;
  }

  /// 下载章节内容并保存到本地
  /// [taskId] 任务唯一标识
  /// [aid] 书籍ID
  /// [cid] 章节ID
  /// [onProgress] 下载进度回调 (已完成字节数, 总字节数)
  Future<String> download({
    required String taskId,
    required String aid,
    required String cid,
    Function(int received, int total)? onProgress,
  }) async {
    // 检查是否已有相同任务在下载
    if (isDownloading(taskId)) {
      throw Exception('任务 $taskId 正在下载中，请勿重复下载');
    }

    // 检查是否已取消
    if (isCanceled(taskId)) {
      throw Exception('任务 $taskId 已被取消');
    }

    // 标记为下载中
    _downloadingStatus[taskId] = true;

    // 创建取消令牌
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    try {
      // 获取存储目录
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory("${dir.path}/cached_chapter");
      if (!(await cacheDir.exists())) {
        await cacheDir.create(recursive: true);
      }
      final savePath = "${cacheDir.path}/${aid}_$cid.txt";

      final url =
          "${ApiService.instance.wenku8Node.node}/modules/article/reader.php?aid=$aid&cid=$cid";

      Log.d("$url ${ApiService.instance.charsetType.name}");

      final result = await ApiService.instance.getNovelContent(
        aid: aid,
        cid: cid,
      );
      if (cancelToken.isCancelled) throw Exception("canceled");
      final String content = switch (result) {
        Success() => result.data as String,
        Error() => throw Exception(result.error),
      };
      onProgress?.call(content.length, content.length);

      // 写入文件（覆盖原有文件）
      final file = File(savePath);
      await file.writeAsString(content, flush: true);

      Log.i('章节 $aid-$cid 下载完成，保存路径：$savePath');
      return savePath;
    } on DioException catch (e) {
      // 处理Dio异常（重点处理取消类型）
      if (e.type == DioExceptionType.cancel) {
        Log.e('任务 $taskId 被取消: ${e.message}');
        throw Exception('canceled');
      } else {
        Log.e('任务 $taskId 下载失败: ${e.message}');
        rethrow;
      }
    } catch (e) {
      // 处理其他异常
      Log.e('任务 $taskId 处理失败: $e');
      rethrow;
    } finally {
      // 无论成功/失败/取消，都清理状态
      _downloadingStatus.remove(taskId);
      _cancelTokens.remove(taskId);
    }
  }

  /// 取消所有正在进行的下载任务
  void cancelAll() {
    _cancelTokens.keys.forEach(cancel);
    _cancelTokens.clear();
    _downloadingStatus.clear();
  }

  /// 清理所有取消令牌和状态
  void dispose() {
    cancelAll();
  }
}
