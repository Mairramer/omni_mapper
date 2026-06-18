import 'package:example/approach_a_abstract_class.dart';
import 'package:example/approach_b_extension_to.dart';
import 'package:example/approach_c_extension_from.dart';
import 'package:example/approach_d_advanced.dart';
import 'package:example/approach_e_update.dart';
import 'package:example/approach_i_enum_mapping.dart';

void main() {
  print('--- Approach A (Abstract Class) ---');
  final modelA = ModelA(id: 1, title: 'Item A');
  final mapperA = MapperAImpl();
  final entityA = mapperA.toEntity(modelA);
  print('Mapped ModelA to EntityA: id=${entityA.id}, title=${entityA.title}\n');

  print('--- Approach B (Extension TO target) ---');
  final modelB = ModelB(id: 2, title: 'Item B');
  final entityB = modelB.toEntity();
  print('Mapped ModelB to EntityB: id=${entityB.id}, title=${entityB.title}\n');

  print('--- Approach C (Extension FROM source) ---');
  final entityC = EntityC(id: 3, title: 'Item C');
  final modelC = entityC.toModel();
  print('Mapped EntityC to ModelC: id=${modelC.id}, title=${modelC.title}\n');
  print('--- Approach D (Advanced Features) ---');
  final advancedModel = AdvancedModel(
    userId: 10,
    title: 'Advanced Item',
    createdAt: '2026-06-17T12:00:00Z',
  );

  final advancedEntity = advancedModel.toEntity();
  print('Mapped AdvancedModel to AdvancedEntity:');
  print('  id=${advancedEntity.id} (from userId)');
  print('  title=${advancedEntity.title}');
  print('  status=${advancedEntity.status} (from defaultValue)');
  print('  createdAt=${advancedEntity.createdAt} (from converter)\n');

  print('Testing Update Method:');
  final existingEntity = AdvancedEntity(id: 0, title: 'Old', status: 'inactive', createdAt: DateTime(2000));
  advancedModel.updateAdvancedEntity(existingEntity);
  print('  Updated existingEntity title: ${existingEntity.title}');

  print('Testing List Mapping:');
  final list = [advancedModel, advancedModel].toEntityList();
  print('  Mapped list length: ${list.length}\n');

  print('Testing Reverse Mapping (Entity -> Model):');
  final backToModel = advancedEntity.toModel();
  print('  userId=${backToModel.userId} (from id)');
  print('  title=${backToModel.title}');
  print('  createdAt=${backToModel.createdAt} (from converter)\n');

  print('--- Approach E (In-Place Update) ---');
  final existingMutableEntity = MutableEntity(id: 1, name: 'Old Name');
  print(
    'Before update: id=${existingMutableEntity.id}, name=${existingMutableEntity.name}, isActive=${existingMutableEntity.isActive}',
  );

  final formModel = FormModel(id: 99, name: 'New Name', isActive: true);
  formModel.updateMutableEntity(existingMutableEntity);

  print(
    'After update: id=${existingMutableEntity.id}, name=${existingMutableEntity.name}, isActive=${existingMutableEntity.isActive}\n',
  );

  print('--- Approach I (Enum Mapping) ---');
  final userModel = UserModel(
    id: 1,
    role: ClientRole.admin,
    secondaryRole: ClientRole.editor,
  );

  final userEntity = userModel.toEntity();
  print('Mapped UserModel to UserEntity:');
  print('  id=${userEntity.id}');
  print('  role=${userEntity.role.name} (mapped from ClientRole.${userModel.role.name})');
  print(
    '  secondaryRole=${userEntity.secondaryRole?.name} (mapped from ClientRole.${userModel.secondaryRole?.name})\n',
  );
}
