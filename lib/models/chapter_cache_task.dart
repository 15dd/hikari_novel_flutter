import 'cache_status.dart';

class ChapterCacheTask {
  String uuid; //唯一id
  String aid;
  String cid;
  String title;
  CacheStatus status;
  double progress; // 0.0 ~ 1.0, -1 表示未知
  Function(String cid)? onCompleted;

  ChapterCacheTask({
    required this.uuid,
    required this.aid,
    required this.cid,
    required this.title,
    this.status = CacheStatus.pending,
    this.progress = 0.0,
    this.onCompleted,
  });

  Map<String, dynamic> toJson() => {"id": uuid, "bookId": aid, "chapterId": cid, "title": title, "status": statusToString(status), "progress": progress};

  factory ChapterCacheTask.fromJson(Map<String, dynamic> json) => ChapterCacheTask(
    uuid: json["id"],
    aid: json["bookId"],
    cid: json["chapterId"],
    title: json["title"],
    status: statusFromString(json["status"] ?? "pending"),
    progress: (json["progress"] ?? 0.0) + 0.0,
  );
}
