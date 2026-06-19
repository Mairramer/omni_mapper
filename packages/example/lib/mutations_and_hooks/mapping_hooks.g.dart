// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapping_hooks.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension HookedUserModelToEntity on HookedUserModel {
  HookedUserEntity toEntity() {
    HookedUserMapperHook().before(this);
    final target = HookedUserEntity(
      id: id,
      name: name,
    );
    HookedUserMapperHook().after(this, target);
    return target;
  }

  void updateHookedUserEntity(HookedUserEntity target) {}
}

extension HookedUserModelToEntityList on Iterable<HookedUserModel> {
  List<HookedUserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
