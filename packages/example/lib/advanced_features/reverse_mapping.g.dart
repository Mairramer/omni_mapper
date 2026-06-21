// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_mapping.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension EntityModelToDto on EntityModel {
  DtoModel toDto() {
    return DtoModel(
      id: userId,
      name: fullName,
      age: age,
      status: 'active',
    );
  }
}

extension EntityModelToDtoList on Iterable<EntityModel> {
  List<DtoModel> toDtoList() {
    return map((e) => e.toDto()).toList();
  }
}

extension DtoModelToEntity on DtoModel {
  EntityModel toEntity() {
    return EntityModel(
      userId: id,
      fullName: name,
      age: age,
    );
  }
}

extension DtoModelToEntityList on Iterable<DtoModel> {
  List<EntityModel> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
