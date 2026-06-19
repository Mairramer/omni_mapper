// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_mappers_example.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class AddressMapperImpl extends AddressMapper {
  AddressMapperImpl.new() : super();

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
  UserMapperImpl.new(AddressMapper addressMapper) : super(addressMapper);

  @override
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      model.name,
      this.addressMapper.toEntity(model.address),
      model.pastAddresses.map((e) => this.addressMapper.toEntity(e)).toList(),
    );
  }

  @override
  UserModel toModel(UserEntity entity) {
    return UserModel(
      entity.name,
      this.addressMapper.toModel(entity.address),
      entity.pastAddresses.map((e) => this.addressMapper.toModel(e)).toList(),
    );
  }
}
