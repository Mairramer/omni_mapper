import 'package:omni_mapper/omni_mapper.dart';

part 'other_mappers_example.g.dart';

// --- Models ---

class AddressModel {
  final String street;
  final String city;

  AddressModel(this.street, this.city);
}

class AddressEntity {
  final String street;
  final String city;

  AddressEntity(this.street, this.city);
}

class UserModel {
  final String name;
  final AddressModel address;
  final List<AddressModel> pastAddresses;

  UserModel(this.name, this.address, this.pastAddresses);
}

class UserEntity {
  final String name;
  final AddressEntity address;
  final List<AddressEntity> pastAddresses;

  UserEntity(this.name, this.address, this.pastAddresses);
}

// --- Mappers ---

// 1. Define the nested mapper
@OmniMapper()
abstract class AddressMapper {
  AddressEntity toEntity(AddressModel model);
  AddressModel toModel(AddressEntity entity);
}

// 2. Define the main mapper, injecting the nested mapper via `uses`
@OmniMapper(uses: [AddressMapper])
abstract class UserMapper {
  // Dependency injection - the generated implementation will pass this
  // to the super constructor.
  final AddressMapper addressMapper;

  UserMapper(this.addressMapper);

  // The generator will automatically use `addressMapper` to map
  // `address` and `pastAddresses`.
  UserEntity toEntity(UserModel model);
  UserModel toModel(UserEntity entity);
}

// --- Usage ---

void main() {
  // Setup mappers
  final addressMapper = AddressMapperImpl();
  final userMapper = UserMapperImpl(addressMapper);

  final user = UserModel(
    'John Doe',
    AddressModel('123 Main St', 'Springfield'),
    [
      AddressModel('456 Elm St', 'Shelbyville'),
      AddressModel('789 Oak St', 'Capital City'),
    ],
  );

  // Map the object and all its nested properties cleanly!
  final entity = userMapper.toEntity(user);

  print('Name: ${entity.name}');
  print('Current City: ${entity.address.city}');
  print('Past Cities: ${entity.pastAddresses.map((a) => a.city).join(', ')}');
}
