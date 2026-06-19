// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_mapping.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension EntityModelToDto on EntityModel {
  DtoModel toDto() {
    final target = DtoModel(
      id: userId,
      name: fullName,
      age: age,
      status: "active",
    );
    return target;
  }

  void updateDtoModel(DtoModel target) {}
}

extension EntityModelToDtoList on Iterable<EntityModel> {
  List<DtoModel> toDtoList() {
    return map((e) => e.toDto()).toList();
  }
}

extension DtoModelToEntity on DtoModel {
  EntityModel toEntity() {
    final target = EntityModel(
      userId: id,
      fullName: name,
      age: age,
    );
    return target;
  }

  void updateEntityModel(EntityModel target) {}
}

extension DtoModelToEntityList on Iterable<DtoModel> {
  List<EntityModel> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
