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

// --- Test 4: Concrete fallback ---
class ConcreteMapper {
  AddressEntity toEntity(AddressModel model) => AddressEntity(model.city);
}

class UserMapperConcreteFallbackImpl extends UserMapperConcreteFallback {
  UserMapperConcreteFallbackImpl();

  @override
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      model.name,
      ConcreteMapper().toEntity(model.address),
      model.pastAddresses.map((e) => ConcreteMapper().toEntity(e)).toList(),
    );
  }
}

@ShouldGenerate(r'''
class UserMapperConcreteFallbackImpl extends UserMapperConcreteFallback {
  UserMapperConcreteFallbackImpl();

  @override
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      model.name,
      ConcreteMapper().toEntity(model.address),
      model.pastAddresses.map((e) => ConcreteMapper().toEntity(e)).toList(),
    );
  }
}
''')
@OmniMapper(uses: [ConcreteMapper])
abstract class UserMapperConcreteFallback {
  UserEntity toEntity(UserModel model);
}

// --- Test 5: Generic wrapper in uses ---
class Wrapper<T> {
  final T value;
  Wrapper(this.value);
}

class WrapperMapper<T, U> {
  Wrapper<U> toWrapper(Wrapper<T> source, U Function(T) mapper) {
    return Wrapper(mapper(source.value));
  }
}

// Wait, the uses resolver looks for methods with 1 parameter!
// Let's make concrete generic mappers that take 1 parameter.
class IntToStringWrapperMapper {
  Wrapper<String> toWrapper(Wrapper<int> source) {
    return Wrapper(source.value.toString());
  }
}

class DoubleToBoolWrapperMapper {
  Wrapper<bool> toWrapper(Wrapper<double> source) {
    return Wrapper(source.value > 0);
  }
}

class GenericSourceModel {
  final Wrapper<int> intWrapper;
  final Wrapper<double> doubleWrapper;
  GenericSourceModel(this.intWrapper, this.doubleWrapper);
}

class GenericTargetModel {
  final Wrapper<String> intWrapper;
  final Wrapper<bool> doubleWrapper;
  GenericTargetModel(this.intWrapper, this.doubleWrapper);
}

class GenericMapperImpl extends GenericMapper {
  GenericMapperImpl(super.intMapper, super.doubleMapper);

  @override
  GenericTargetModel toTarget(GenericSourceModel model) {
    return GenericTargetModel(
      intMapper.toWrapper(model.intWrapper),
      doubleMapper.toWrapper(model.doubleWrapper),
    );
  }
}

@ShouldGenerate(r'''
class GenericMapperImpl extends GenericMapper {
  GenericMapperImpl(super.intMapper, super.doubleMapper);

  @override
  GenericTargetModel toTarget(GenericSourceModel model) {
    return GenericTargetModel(
      intMapper.toWrapper(model.intWrapper),
      doubleMapper.toWrapper(model.doubleWrapper),
    );
  }
}
''')
@OmniMapper(uses: [IntToStringWrapperMapper, DoubleToBoolWrapperMapper])
abstract class GenericMapper {
  final IntToStringWrapperMapper intMapper;
  final DoubleToBoolWrapperMapper doubleMapper;

  GenericMapper(this.intMapper, this.doubleMapper);

  GenericTargetModel toTarget(GenericSourceModel model);
}

// --- Test 6: Uses with nullable source and default value ---
class ConcreteNullableMapper {
  String toEntity(String source) => 'Mapped $source';
}

class UsesNullableSourceModel {
  final String? optionalString;
  UsesNullableSourceModel(this.optionalString);
}

class UsesNonNullableTargetModel {
  final String optionalString;
  UsesNonNullableTargetModel(this.optionalString);
}

@ShouldGenerate(r'''
class UsesNullableMapperImpl extends UsesNullableMapper {
  UsesNullableMapperImpl();

  @override
  UsesNonNullableTargetModel toTarget(UsesNullableSourceModel model) {
    return UsesNonNullableTargetModel(
      model.optionalString != null
          ? ConcreteNullableMapper().toEntity((model.optionalString)!)
          : 'default',
    );
  }
}
''')
@OmniMapper(
  uses: [ConcreteNullableMapper],
  mappings: [
    MappingRule('optionalString', defaultValue: 'default'),
  ],
)
abstract class UsesNullableMapper {
  UsesNonNullableTargetModel toTarget(UsesNullableSourceModel model);
}

// --- Test 7: Uses with nullable source list and default value ---
class ConcreteListNullableMapper {
  String toEntity(String source) => 'Mapped $source';
}

class UsesNullableListSourceModel {
  final List<String>? optionalList;
  UsesNullableListSourceModel(this.optionalList);
}

class UsesNonNullableListTargetModel {
  final List<String> optionalList;
  UsesNonNullableListTargetModel(this.optionalList);
}

@ShouldGenerate(r'''
class UsesNullableListMapperImpl extends UsesNullableListMapper {
  UsesNullableListMapperImpl();

  @override
  UsesNonNullableListTargetModel toTarget(UsesNullableListSourceModel model) {
    return UsesNonNullableListTargetModel(
      model.optionalList
              ?.map((e) => ConcreteListNullableMapper().toEntity(e))
              .toList() ??
          const [],
    );
  }
}
''')
@OmniMapper(
  uses: [ConcreteListNullableMapper],
  mappings: [
    MappingRule('optionalList', defaultValue: []),
  ],
)
abstract class UsesNullableListMapper {
  UsesNonNullableListTargetModel toTarget(UsesNullableListSourceModel model);
}
