import 'package:omni_mapper/omni_mapper.dart';

part 'approach_l_multiple_sources.g.dart';

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
  
  // Custom mapped field
  final String fullAddress;

  UserProfile({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.fullAddress,
  });

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, fullAddress: $fullAddress)';
  }
}

@OmniMapper(
  fieldMaps: {
    // We map fullAddress from the street field just for demonstration,
    // though in a real scenario you might want a custom expression or hook.
    'address.street': 'fullAddress',
  },
)
abstract class UserProfileMapper {
  UserProfile toProfile(User user, Address address);
}
