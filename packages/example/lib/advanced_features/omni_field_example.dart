import 'package:omni_mapper/omni_mapper.dart';

part 'omni_field_example.g.dart';

/// Scenario 1: Using @OmniField on a Source class
///
/// The [UserEntity] is the target. We cannot or do not want to modify it.
class UserEntity {
  final int userId;
  final String userFullName;
  final String status;

  UserEntity({
    required this.userId,
    required this.userFullName,
    required this.status,
  });
}

/// The [UserModel] is our local model, annotated with @OmniMapper.
/// We use @OmniField to map its properties to [UserEntity]'s properties.
@OmniMapper(target: UserEntity)
class UserModel {
  @OmniField(name: 'userId')
  final int id;

  @OmniField(name: 'userFullName')
  final String name;

  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.status,
  });
}

/// Scenario 2: Using @OmniField on a Target class
///
/// The [AdminModel] is the source. We cannot modify it.
class AdminModel {
  final int adminId;
  final String accessLevel;

  AdminModel(this.adminId, this.accessLevel);
}

/// The [AdminEntity] is our target class. We use `from` in @OmniMapper.
/// We use @OmniField to map its properties from [AdminModel]'s properties.
@OmniMapper(from: AdminModel)
class AdminEntity {
  @OmniField(name: 'adminId')
  final int id;

  @OmniField(name: 'accessLevel')
  final String role;

  AdminEntity(this.id, this.role);
}

void main() {
  // Scenario 1
  final userModel = UserModel(id: 1, name: 'Alice', status: 'ACTIVE');
  final userEntity = userModel.toEntity();
  print(
    'UserEntity: ${userEntity.userId}, ${userEntity.userFullName}, ${userEntity.status}',
  );

  // Scenario 2
  final adminModel = AdminModel(99, 'SUPER_ADMIN');
  final adminEntity = adminModel.toEntity();
  print('AdminEntity: ${adminEntity.id}, ${adminEntity.role}');
}
