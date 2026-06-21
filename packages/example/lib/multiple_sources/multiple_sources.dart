import 'package:omni_mapper/omni_mapper.dart';

part 'multiple_sources.g.dart';

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

class Address {
  final String street;
  final String city;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.zipCode,
  });
}

class UserProfile {
  final String id;
  final String name;
  final String street;
  final String city;
  final String zipCode;

  // Custom mapped field (non-final to allow mutation in hook)
  String fullAddress;

  UserProfile({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.zipCode,
    this.fullAddress = '',
  });

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, fullAddress: $fullAddress)';
  }
}

class UserProfileHook extends OmniHook<User, UserProfile> {
  const UserProfileHook();

  @override
  void after(User source, UserProfile target) {
    // Note: OmniHook currently receives only the primary (first) source.
    // So we use the User's name to generate the fullAddress in this example.
    target.fullAddress =
        '${source.name} lives at ${target.street}, ${target.city} - ${target.zipCode}';
  }
}

@OmniMapper(
  mappings: [
    MappingRule('fullAddress', ignore: true),
  ],
  hook: UserProfileHook,
)
abstract class UserProfileMapper {
  UserProfile toProfile(User user, Address address);
}
