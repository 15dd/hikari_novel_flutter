enum CharsetType { gbk, big5Hkscs }

extension CharsetTypeDesc on CharsetType {
  String get name => ["gbk", "big5-hkscs"][index];
}
