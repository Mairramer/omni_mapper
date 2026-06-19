// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiple_sources.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class UserProfileMapperImpl extends UserProfileMapper {
  @override
  UserProfile toProfile(
    User user,
    Address address,
  ) {
    UserProfileHook().before(user);
    final target = UserProfile(
      id: user.id,
      name: user.name,
      street: address.street,
      city: address.city,
      zipCode: address.zipCode,
    );
    UserProfileHook().after(user, target);
    return target;
  }
}
