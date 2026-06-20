// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_converters.dart';

// **************************************************************************
// MultiMapperGenerator
// **************************************************************************

extension AdvancedModelToEntity on AdvancedModel {
  AdvancedEntity toEntity() {
    return AdvancedEntity(
      id: userId,
      title: title,
      status: 'active',
      createdAt: const DateTimeStringConverter().convert(createdAt),
    );
  }
}

extension AdvancedModelToEntityList on Iterable<AdvancedModel> {
  List<AdvancedEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}

extension AdvancedEntityToModel on AdvancedEntity {
  AdvancedModel toModel() {
    return AdvancedModel(
      userId: id,
      title: title,
      createdAt: const StringDateTimeConverter().convert(createdAt),
    );
  }
}

extension AdvancedEntityToModelList on Iterable<AdvancedEntity> {
  List<AdvancedModel> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
