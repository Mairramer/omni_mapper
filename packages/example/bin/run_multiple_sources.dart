import 'package:example/multiple_sources/multiple_sources.dart';

void main() {
  final user = User(id: '123', name: 'John Doe');
  final address = Address(
    street: '123 Main St',
    city: 'New York',
    zipCode: '10001',
  );

  final mapper = UserProfileMapperImpl();
  final profile = mapper.toProfile(user, address);

  print('Multiple Sources Mapping Result:');
  print(profile);
}
