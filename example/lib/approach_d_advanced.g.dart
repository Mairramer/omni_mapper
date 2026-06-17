// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_d_advanced.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension AdvancedModelToEntity on AdvancedModel {
  AdvancedEntity toEntity() {
    return AdvancedEntity(
      id: userId,
      title: title,
      status: "active",
      createdAt: const DateTimeStringConverter().convert(createdAt),
    );
  }

  void updateAdvancedEntity(AdvancedEntity target) {}
}

extension AdvancedModelToEntityList on Iterable<AdvancedModel> {
  List<AdvancedEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
