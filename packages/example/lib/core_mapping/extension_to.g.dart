// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_to.dart';

// **************************************************************************
// MultiMapperGenerator
// **************************************************************************

extension ModelBToEntity on ModelB {
  EntityB toEntity() {
    return EntityB(
      id: id,
      title: title,
    );
  }

  void updateEntityB(EntityB target) {}
}

extension ModelBToEntityList on Iterable<ModelB> {
  List<EntityB> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}

extension ModelBToEntityB2 on ModelB {
  EntityB2 toEntityB2() {
    return EntityB2(
      id: id,
      title: title,
    );
  }

  void updateEntityB2(EntityB2 target) {}
}

extension ModelBToEntityB2List on Iterable<ModelB> {
  List<EntityB2> toEntityB2List() {
    return map((e) => e.toEntityB2()).toList();
  }
}
