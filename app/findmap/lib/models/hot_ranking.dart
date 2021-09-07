import 'package:json_annotation/json_annotation.dart';

part 'hot_ranking.g.dart';

@JsonSerializable()
class HotRanking {
  String word;
  int ranking;
  String changes;

  HotRanking(this.word, this.ranking, this.changes);

  factory HotRanking.fromJson(Map<String, dynamic> json) => _$HotRankingFromJson(json);

  Map<String, dynamic> toJson() => _$HotRankingToJson(this);
}