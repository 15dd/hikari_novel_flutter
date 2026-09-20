import 'dart:convert';

import 'package:hikari_novel_flutter/models/cat_volume.dart';
import 'package:json_annotation/json_annotation.dart';

part 'novel_detail.g.dart';

@JsonSerializable(explicitToJson: true)
class NovelDetail {
  final String title;
  final String author;
  final String status;
  final String finUpdate;
  final String imgUrl;
  final String introduce;
  final List<String> tags;
  final String heat;
  final String trending;
  final bool isAnimated;
  List<CatVolume> catalogue = [];

  NovelDetail(this.title, this.author, this.status, this.finUpdate, this.imgUrl, this.introduce, this.tags, this.heat, this.trending, this.isAnimated);

  factory NovelDetail.fromJson(Map<String, dynamic> json) => _$NovelDetailFromJson(json);

  Map<String, dynamic> toJson() => _$NovelDetailToJson(this);

  @override
  String toString() => jsonEncode(toJson());

  factory NovelDetail.fromString(String json) => NovelDetail.fromJson(jsonDecode(json));
}
