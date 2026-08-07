enum CacheStatus { pending, downloading, paused, completed, failed, canceled }

String statusToString(CacheStatus s) => s.toString().split('.').last;

CacheStatus statusFromString(String s) => CacheStatus.values.firstWhere((e) => e.toString().split('.').last == s, orElse: () => CacheStatus.pending);
