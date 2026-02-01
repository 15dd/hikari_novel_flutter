import 'package:get/get.dart';

import '../../models/cache_status.dart';
import '../../models/chapter_cache_task.dart';
import '../../network/chapter_downloader.dart';

class CacheQueueController extends GetxService {
  final downloader = ChapterDownloader();

  //可观察队列
  final RxList<ChapterCacheTask> tasks = <ChapterCacheTask>[].obs;

  //控制并发数量
  final int concurrency;

  //内部状态
  bool _isProcessing = false;
  final Map<String, Future> _running = {}; // taskId -> future

  CacheQueueController({this.concurrency = 1});

  //添加任务，会自动去重（基于uuid）
  Future<void> addTask(ChapterCacheTask t) async {
    final idx = tasks.indexWhere((x) => x.uuid == t.uuid);
    if (idx != -1) {
      //已存在, 更新一些字段
      final old = tasks[idx];
      old.title = t.title;
      tasks[idx] = old;
    } else {
      tasks.add(t);
    }
    startProcessing();
  }

  Future<void> removeTask(String uuid) async {
    // 如果正在下载，先取消
    downloader.cancel(uuid);
    tasks.removeWhere((t) => t.uuid == uuid);
  }

  Future<void> startProcessing() async {
    if (_isProcessing) return;
    _isProcessing = true;
    _processLoop();
  }

  Future<void> _processLoop() async {
    while (_isProcessing) {
      // 启动新的任务直到并发限制
      final runningCount = _running.length;
      if (runningCount >= concurrency) {
        // 等待最先完成的任务
        await Future.delayed(Duration(milliseconds: 300));
        continue;
      }

      // 找到下一个 pending 任务
      final next = tasks.where((t) => t.status == CacheStatus.pending).toList();
      if (next.isEmpty) {
        // 没有更多任务，停止循环
        _isProcessing = false;
        break;
      }

      final task = next.first;
      // 启动下载
      task.status = CacheStatus.downloading;
      task.progress = 0.0;
      // 确保 UI 更新
      tasks.refresh();

      final future = _runTask(task).whenComplete(() {
        _running.remove(task.uuid);
      });
      _running[task.uuid] = future;

      // 小睡一下让 loop 再次评估并发
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> _runTask(ChapterCacheTask task) async {
    try {
      await downloader.download(taskId: task.uuid, aid: task.aid, cid: task.cid);

      // task.status = CacheStatus.completed;
      // task.progress = 1.0;

      tasks.remove(task);
      tasks.refresh();
      task.onCompleted?.call(task.cid);
    } catch (e) {
      if (e.toString().contains('canceled')) {
        task.status = CacheStatus.canceled;
      } else {
        task.status = CacheStatus.failed;
      }
      tasks.refresh();
    }
  }

  Future<void> pauseTask(String uuid) async {
    //无法精确暂停，只能取消并把状态标记为paused
    downloader.cancel(uuid);
    final idx = tasks.indexWhere((t) => t.uuid == uuid);
    if (idx != -1) {
      final t = tasks[idx];
      t.status = CacheStatus.paused;
      tasks[idx] = t;
    }
  }

  Future<void> resumeTask(String uuid) async {
    final idx = tasks.indexWhere((t) => t.uuid == uuid);
    if (idx != -1) {
      final t = tasks[idx];
      if (t.status == CacheStatus.paused || t.status == CacheStatus.failed || t.status == CacheStatus.canceled) {
        t.status = CacheStatus.pending;
        tasks[idx] = t;
        startProcessing(); // 确保会重新从头开始下载
      }
    }
  }


  Future<void> cancelTask(String uuid) async {
    downloader.cancel(uuid);
    final idx = tasks.indexWhere((t) => t.uuid == uuid);
    if (idx != -1) {
      final t = tasks[idx];
      t.status = CacheStatus.canceled;
      tasks[idx] = t;
    }
  }

  Future<void> startAll() async {
    for (var t in tasks) {
      if (t.status != CacheStatus.completed) t.status = CacheStatus.pending;
    }
    tasks.refresh();
    startProcessing();
  }

  Future<void> pauseAll() async {
    _isProcessing = false;
    //取消 running
    for (var k in _running.keys) {
      downloader.cancel(k);
    }
    for (var t in tasks) {
      if (t.status == CacheStatus.downloading) t.status = CacheStatus.paused;
    }
    tasks.refresh();
  }

  Future<void> clearAll() async {
    tasks.clear();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = tasks.toList();
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    tasks.assignAll(list);
  }
}