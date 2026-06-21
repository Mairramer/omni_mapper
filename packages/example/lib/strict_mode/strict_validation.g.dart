// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strict_validation.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension StrictUserModelToEntity on StrictUserModel {
  StrictUserEntity toEntity() {
    return StrictUserEntity(
      id: id,
      name: name,
    );
  }
}

extension StrictUserModelToEntityList on Iterable<StrictUserModel> {
  List<StrictUserEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
