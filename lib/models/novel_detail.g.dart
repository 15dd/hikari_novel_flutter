// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NovelDetail _$NovelDetailFromJson(Map<String, dynamic> json) => NovelDetail(
  json['title'] as String,
  json['author'] as String,
  json['status'] as String,
  json['finUpdate'] as String,
  json['imgUrl'] as String,
  json['introduce'] as String,
  (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  json['heat'] as String,
  json['trending'] as String,
  json['isAnimated'] as bool,
)..catalogue = (json['catalogue'] as List<dynamic>).map((e) => CatVolume.fromJson(e as Map<String, dynamic>)).toList();

Map<String, dynamic> _$NovelDetailToJson(NovelDetail instance) => <String, dynamic>{
  'title': instance.title,
  'author': instance.author,
  'status': instance.status,
  'finUpdate': instance.finUpdate,
  'imgUrl': instance.imgUrl,
  'introduce': instance.introduce,
  'tags': instance.tags,
  'heat': instance.heat,
  'trending': instance.trending,
  'isAnimated': instance.isAnimated,
  'catalogue': instance.catalogue.map((e) => e.toJson()).toList(),
};
