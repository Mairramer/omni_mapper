// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ignore_if_null.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension PatchUserModelToEntity on PatchUserModel {
  PatchUserEntity toEntity() {
    return PatchUserEntity(
      id: id,
      name: name,
      bio: bio,
    );
  }

  void updatePatchUserEntity(PatchUserEntity target) {
    if (id case final id?) {
      target.id = id;
    }
    if (name case final name?) {
      target.name = name;
    }
    if (bio case final bio?) {
      target.bio = bio;
    }
  }
}

extension PatchUserModelToEntityList on Iterable<PatchUserModel> {
  List<PatchUserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
