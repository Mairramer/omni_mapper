// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_mappers_example.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class AddressMapperImpl extends AddressMapper {
  AddressMapperImpl();

  @override
  AddressEntity toEntity(AddressModel model) {
    return AddressEntity(
      model.street,
      model.city,
    );
  }

  @override
  AddressModel toModel(AddressEntity entity) {
    return AddressModel(
      entity.street,
      entity.city,
    );
  }
}

class UserMapperImpl extends UserMapper {
  UserMapperImpl(super.addressMapper);

  @override
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      model.name,
      addressMapper.toEntity(model.address),
      model.pastAddresses.map((e) => addressMapper.toEntity(e)).toList(),
    );
  }

  @override
  UserModel toModel(UserEntity entity) {
    return UserModel(
      entity.name,
      addressMapper.toModel(entity.address),
      entity.pastAddresses.map((e) => addressMapper.toModel(e)).toList(),
    );
  }
}
