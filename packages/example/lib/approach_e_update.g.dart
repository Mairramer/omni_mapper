// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_e_update.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension FormModelToEntity on FormModel {
  MutableEntity toEntity() {
    final target = MutableEntity(id: id, name: name, isActive: isActive);
    return target;
  }

  void updateMutableEntity(MutableEntity target) {
    target.id = this.id;
    target.name = this.name;
    target.isActive = this.isActive;
  }
}

extension FormModelToEntityList on Iterable<FormModel> {
  List<MutableEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
