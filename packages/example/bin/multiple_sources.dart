import 'package:example/multiple_sources/multiple_sources.dart';

void main() {
  print('\n🔵 Multiple Sources');
  print('---------------------------------------------------');

  print('\n[Approach L] Mapping from multiple parameters');
  final user = User(id: 'u123', name: 'Charlie');
  final address = Address(
    street: '123 Main St',
    city: 'Metropolis',
    zipCode: '10001',
  );
  final userProfileMapper = UserProfileMapperImpl();

  final userProfile = userProfileMapper.toProfile(user, address);
  print('  ↳ Aggregated UserProfile:');
  print('  ↳   id=${userProfile.id}');
  print('  ↳   name=${userProfile.name}');
  print(
    '  ↳   address=${userProfile.street}, ${userProfile.city} - ${userProfile.zipCode}',
  );
  print('  ↳   hook computed fullAddress: "${userProfile.fullAddress}"');
}
