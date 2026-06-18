// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_i_enum_mapping.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension UserModelToEntity on UserModel {
  UserEntity toEntity() {
    final target = UserEntity(
      id: id,
      role: UserRole.values.byName(role.name),
      secondaryRole: secondaryRole != null ? UserRole.values.byName(secondaryRole!.name) : null,
    );
    return target;
  }

  void updateUserEntity(UserEntity target) {}
}

extension UserModelToEntityList on Iterable<UserModel> {
  List<UserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
