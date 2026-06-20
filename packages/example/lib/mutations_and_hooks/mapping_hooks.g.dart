// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapping_hooks.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension HookedUserModelToEntity on HookedUserModel {
  HookedUserEntity toEntity() {
    const HookedUserMapperHook().before(this);
    final target = HookedUserEntity(
      id: id,
      name: name,
    );
    const HookedUserMapperHook().after(this, target);
    return target;
  }
}

extension HookedUserModelToEntityList on Iterable<HookedUserModel> {
  List<HookedUserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
