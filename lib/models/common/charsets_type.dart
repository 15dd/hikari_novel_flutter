enum CharsetsType { gbk, big5Hkscs }

extension CharsetsTypeDesc on CharsetsType {
  String get name => ["gbk", "big5-hkscs"][index];
}
