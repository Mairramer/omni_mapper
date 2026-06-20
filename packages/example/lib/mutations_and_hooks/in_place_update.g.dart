// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_place_update.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension FormModelToEntity on FormModel {
  MutableEntity toEntity() {
    return MutableEntity(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  void updateMutableEntity(MutableEntity target) {
    target.id = id;
    target.name = name;
    target.isActive = isActive;
  }
}

extension FormModelToEntityList on Iterable<FormModel> {
  List<MutableEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
