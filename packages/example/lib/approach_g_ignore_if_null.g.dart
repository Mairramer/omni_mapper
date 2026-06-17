// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_g_ignore_if_null.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension PatchUserModelToEntity on PatchUserModel {
  PatchUserEntity toEntity() {
    final target = PatchUserEntity(id: id, name: name, bio: bio);
    return target;
  }

  void updatePatchUserEntity(PatchUserEntity target) {
    if (this.id != null) target.id = this.id!;
    if (this.name != null) target.name = this.name!;
    if (this.bio != null) target.bio = this.bio!;
  }
}

extension PatchUserModelToEntityList on Iterable<PatchUserModel> {
  List<PatchUserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
