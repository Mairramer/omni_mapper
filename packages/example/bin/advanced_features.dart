import 'package:example/advanced_features/auto_flattening.dart';
import 'package:example/advanced_features/enum_mapping.dart';
import 'package:example/advanced_features/field_converters.dart';
import 'package:example/advanced_features/reverse_mapping.dart';

void main() {
  print('\n🔵 Advanced Mapping Features');
  print('---------------------------------------------------');

  print('\n[Approach D] Field Maps, Converters & Default Values');
  final advancedModel = AdvancedModel(
    userId: 10,
    title: 'Advanced Item',
    createdAt: '2026-06-17T12:00:00Z',
  );
  final advancedEntity = advancedModel.toEntity();
  print('  ↳ id=${advancedEntity.id} (from userId)');
  print('  ↳ title=${advancedEntity.title}');
  print('  ↳ status=${advancedEntity.status} (from defaultValue)');
  print('  ↳ createdAt=${advancedEntity.createdAt} (from string converter)');
  print(
    '  ↳ List mapping length: ${[advancedModel, advancedModel].toEntityList().length}',
  );

  print('\n[Approach I] Enum Mapping');
  final userModel = UserModel(
    id: 1,
    role: ClientRole.admin,
    secondaryRole: ClientRole.editor,
  );
  final userEntity = userModel.toEntity();
  print('  ↳ id=${userEntity.id}');
  print(
    '  ↳ role=${userEntity.role.name} (mapped from ClientRole.${userModel.role.name})',
  );
  print(
    '  ↳ secondaryRole=${userEntity.secondaryRole?.name} (mapped from ClientRole.${userModel.secondaryRole?.name})',
  );

  print('\n[Approach J] Auto-Flattening');
  final flattenModel = FlattenModel(
    userAddress: Address(city: City(name: 'San Francisco')),
    profile: Profile(
      settings: Settings(
        theme: Theme(id: 'dark_01', mode: 'dark'),
      ),
    ),
  );
  final flattenTarget = flattenModel.toEntity();
  print('  ↳ userAddressCityName=${flattenTarget.userAddressCityName}');
  print('  ↳ profileSettingsThemeId=${flattenTarget.profileSettingsThemeId}');
  print(
    '  ↳ profileSettingsThemeMode=${flattenTarget.profileSettingsThemeMode}',
  );

  print('\n[Approach K] Reverse Mapping');
  const entityModelK = EntityModel(userId: 'u123', fullName: 'Alice', age: 30);
  final dtoModel = entityModelK.toDto();
  print(
    '  ↳ Entity -> Dto: id=${dtoModel.id}, name=${dtoModel.name}, age=${dtoModel.age}',
  );

  final reversedEntity = dtoModel.toEntity();
  print(
    '  ↳ Dto -> Entity: userId=${reversedEntity.userId}, fullName=${reversedEntity.fullName}, age=${reversedEntity.age}',
  );
}
