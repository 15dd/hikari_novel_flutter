// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_volume.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatVolume _$CatVolumeFromJson(Map<String, dynamic> json) => CatVolume(
  title: json['title'] as String,
  chapters: (json['chapters'] as List<dynamic>).map((e) => CatChapter.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$CatVolumeToJson(CatVolume instance) => <String, dynamic>{
  'title': instance.title,
  'chapters': instance.chapters.map((e) => e.toJson()).toList(),
};
