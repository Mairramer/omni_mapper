import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/annotations.dart';

// --- Source and Target Models ---

class AddressModel {
  final String city;
  AddressModel(this.city);
}

class AddressEntity {
  final String city;
  AddressEntity(this.city);
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

// --- Delegate Mapper ---

@OmniMapper()
abstract class AddressMapper {
  AddressEntity toEntity(AddressModel model);
}

// --- Test 1: DI Injection (Uses field) ---

@ShouldGenerate(r'''
class UserMapperDIImpl extends UserMapperDI {
  UserMapperDIImpl(super.addressMapper);

  @override
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      model.name,
      addressMapper.toEntity(model.address),
      model.pastAddresses.map((e) => addressMapper.toEntity(e)).toList(),
    );
  }
}
''')
@OmniMapper(uses: [AddressMapper])
abstract class UserMapperDI {
  final AddressMapper addressMapper;
  UserMapperDI(this.addressMapper);

  UserEntity toEntity(UserModel model);
}

// --- Test 2: Fallback Instantiation ---

@ShouldGenerate(r'''
class UserMapperFallbackImpl extends UserMapperFallback {
  UserMapperFallbackImpl();

  @override
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      model.name,
      AddressMapperImpl().toEntity(model.address),
      model.pastAddresses.map((e) => AddressMapperImpl().toEntity(e)).toList(),
    );
  }
}
''')
@OmniMapper(uses: [AddressMapper])
abstract class UserMapperFallback {
  UserEntity toEntity(UserModel model);
}

// --- Test 3: Extension Fallback ---

class ExtTarget {
  final AddressEntity address;
  final List<AddressEntity> pastAddresses;
  ExtTarget(this.address, this.pastAddresses);
}

@ShouldGenerate(r'''
extension ExtSourceToEntity on ExtSource {
  ExtTarget toEntity() {
    return ExtTarget(
      AddressMapperImpl().toEntity(address),
      pastAddresses.map((e) => AddressMapperImpl().toEntity(e)).toList(),
    );
  }

  void updateExtTarget(ExtTarget target) {}
}

extension ExtSourceToEntityList on Iterable<ExtSource> {
  List<ExtTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(target: ExtTarget, uses: [AddressMapper])
class ExtSource {
  final AddressModel address;
  final List<AddressModel> pastAddresses;

  ExtSource(this.address, this.pastAddresses);
}
