import 'package:omni_mapper/omni_mapper.dart';

part 'approach_i_enum_mapping.g.dart';

enum UserRole { admin, editor, viewer }

enum ClientRole { admin, editor, viewer, guest }

class UserEntity {
  final int id;
  final UserRole role;
  final UserRole? secondaryRole;

  UserEntity({
    required this.id,
    required this.role,
    this.secondaryRole,
  });
}

@OmniMapper(target: UserEntity)
class UserModel {
  final int id;
  final ClientRole role;
  final ClientRole? secondaryRole;

  UserModel({
    required this.id,
    required this.role,
    this.secondaryRole,
  });
}
