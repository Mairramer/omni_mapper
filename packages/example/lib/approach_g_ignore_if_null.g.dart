// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_g_ignore_if_null.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension PatchUserModelToEntity on PatchUserModel {
  PatchUserEntity toEntity() {
    final target = PatchUserEntity(
      id: id,
      name: name,
      bio: bio,
    );
    return target;
  }

  void updatePatchUserEntity(PatchUserEntity target) {
    if (this.id case final id?) target.id = id;
    if (this.name case final name?) target.name = name;
    if (this.bio case final bio?) target.bio = bio;
  }
}

extension PatchUserModelToEntityList on Iterable<PatchUserModel> {
  List<PatchUserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
