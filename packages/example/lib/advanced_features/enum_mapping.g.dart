// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_mapping.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension UserModelToEntity on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      role: UserRole.values.byName(role.name),
      secondaryRole: secondaryRole != null
          ? UserRole.values.byName((secondaryRole)!.name)
          : null,
    );
  }

  void updateUserEntity(UserEntity target) {}
}

extension UserModelToEntityList on Iterable<UserModel> {
  List<UserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
