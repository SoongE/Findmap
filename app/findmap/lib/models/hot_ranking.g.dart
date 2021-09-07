// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotRanking _$HotRankingFromJson(Map<String, dynamic> json) {
  return HotRanking(
    json['word'] as String,
    json['ranking'] as int,
    json['changes'] as String,
  );
}

Map<String, dynamic> _$HotRankingToJson(HotRanking instance) =>
    <String, dynamic>{
      'word': instance.word,
      'ranking': instance.ranking,
      'changes': instance.changes,
    };
