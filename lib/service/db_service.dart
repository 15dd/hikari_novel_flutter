import 'package:get/get.dart';

import '../common/database/database.dart';

class DBService extends GetxService {
  static DBService get instance => Get.find<DBService>();

  late final AppDatabase _db;

  void init() {
    _db = AppDatabase();
  }

  Future<void> insertAllBookshelf(Iterable<BookshelfEntityData> data) => _db.insertAllBookshelf(data);

  Future<void> deleteAllBookshelf() => _db.deleteAllBookshelf();

  Future<void> deleteDefaultBookshelf() => _db.deleteDefaultBookshelf();

  Stream<List<BookshelfEntityData>> getBookshelfByClassId(String classId) => _db.getBookshelfByClassId(classId);

  Future<List<BookshelfEntityData>> getAllBookshelf() => _db.getAllBookshelf();

  Future<List<BookshelfEntityData>> getBookshelfByKeyword(String keyword) => _db.getBookshelfByKeyword(keyword);

  Future<void> upsertBrowsingHistory(BrowsingHistoryEntityData data) => _db.upsertBrowsingHistory(data);

  Stream<List<BrowsingHistoryEntityData>> getWatchableAllBrowsingHistory() => _db.getWatchableAllBrowsingHistory();

  Future<void> deleteBrowsingHistory(String aid) => _db.deleteBrowsingHistory(aid);

  Future<void> deleteAllBrowsingHistory() => _db.deleteAllBrowsingHistory();

  Future<void> upsertSearchHistory(SearchHistoryEntityData data) => _db.upsertSearchHistory(data);

  Stream<List<SearchHistoryEntityData>> getAllSearchHistory() => _db.getAllSearchHistory();

  Future<void> deleteAllSearchHistory() => _db.deleteAllSearchHistory();

  Future<void> upsertReadHistory(ReadHistoryEntityData data) => _db.upsertReadHistory(data);

  Future<ReadHistoryEntityData?> getReadHistoryByCid(String cid) => _db.getReadHistoryByCid(cid);

  Stream<ReadHistoryEntityData?> getLastestReadHistoryByAid(String aid) => _db.getLastestReadHistoryByAid(aid);

  Stream<ReadHistoryEntityData?> getWatchableReadHistoryByCid(String cid) => _db.getWatchableReadHistoryByCid(cid);

  Stream<List<ReadHistoryEntityData>> getWatchableReadHistoryByVolume(List<String> cids) => _db.getWatchableReadHistoryByVolume(cids);

  Future<void> deleteReadHistoryByCid(String cid) => _db.deleteReadHistoryByCid(cid);

  Future<void> upsertReadHistoryDirectly(ReadHistoryEntityData data) => _db.upsertReadHistoryDirectly(data);

  Future<void> deleteAllReadHistory() => _db.deleteAllReadHistory();

  Future<void> upsertNovelDetail(NovelDetailEntityData data) => _db.upsertNovelDetail(data);

  Future<NovelDetailEntityData?> getNovelDetail(String aid) => _db.getNovelDetail(aid);

  Future<void> deleteAllNovelDetail() => _db.deleteAllNovelDetail();
}
