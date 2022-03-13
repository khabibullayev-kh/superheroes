import 'package:json_annotation/json_annotation.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:collection/collection.dart';

part 'biography.g.dart';

@JsonSerializable()
class Biography {
  final String fullName;
  final String alignment;
  final List<String> aliases;
  final String placeOfBirth;

  Biography({
    required this.fullName,
    required this.alignment,
    required this.aliases,
    required this.placeOfBirth,
  });

  factory Biography.fromJson(final Map<String, dynamic> json) =>
      _$BiographyFromJson(json);

  Map<String, dynamic> toJson() => _$BiographyToJson(this);

  AlignmentInfo? get alignmentInfo => AlignmentInfo.fromAlignment(alignment);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Biography &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          alignment == other.alignment &&
          ListEquality<String>().equals(aliases, other.aliases) &&
          placeOfBirth == other.placeOfBirth;

  @override
  int get hashCode =>
      fullName.hashCode ^
      alignment.hashCode ^
      aliases.hashCode ^
      placeOfBirth.hashCode;

  @override
  String toString() {
    return 'Biography{fullName: $fullName, alignment: $alignment, aliases: $aliases, placeOfBirth: $placeOfBirth}';
  }
}
