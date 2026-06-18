// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_b_extension_to.dart';

// **************************************************************************
// MultiMapperGenerator
// **************************************************************************

extension ModelBToEntity on ModelB {
  EntityB toEntity() {
    final target = EntityB(
      id: id,
      title: title,
    );
    return target;
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
    final target = EntityB2(
      id: id,
      title: title,
    );
    return target;
  }

  void updateEntityB2(EntityB2 target) {}
}

extension ModelBToEntityB2List on Iterable<ModelB> {
  List<EntityB2> toEntityB2List() {
    return map((e) => e.toEntityB2()).toList();
  }
}
