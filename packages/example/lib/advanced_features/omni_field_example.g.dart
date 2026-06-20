// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omni_field_example.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension UserModelToEntity on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      userId: id,
      userFullName: name,
      status: status,
    );
  }
}

extension UserModelToEntityList on Iterable<UserModel> {
  List<UserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}

extension AdminModelToEntity on AdminModel {
  AdminEntity toEntity() {
    return AdminEntity(
      adminId,
      accessLevel,
    );
  }
}

extension AdminModelToEntityList on Iterable<AdminModel> {
  List<AdminEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
