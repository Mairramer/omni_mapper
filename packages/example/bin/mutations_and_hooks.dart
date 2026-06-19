import 'package:example/mutations_and_hooks/ignore_if_null.dart';
import 'package:example/mutations_and_hooks/in_place_update.dart';
import 'package:example/mutations_and_hooks/mapping_hooks.dart';

void main() {
  print('\n🔵 Mutations and Hooks');
  print('---------------------------------------------------');

  print('\n[Approach E] In-Place Update');
  final existingMutableEntity = MutableEntity(id: 1, name: 'Old Name');
  print(
    '  ↳ Before: id=${existingMutableEntity.id}, name=${existingMutableEntity.name}, isActive=${existingMutableEntity.isActive}',
  );
  final formModel = FormModel(id: 99, name: 'New Name', isActive: true);
  formModel.updateMutableEntity(existingMutableEntity);
  print(
    '  ↳ After:  id=${existingMutableEntity.id}, name=${existingMutableEntity.name}, isActive=${existingMutableEntity.isActive}',
  );

  print('\n[Approach G] Ignore If Null (PATCH style)');
  final patchEntity = PatchUserEntity(id: 1, name: 'Old Name', bio: 'Old Bio');
  final patchModel = PatchUserModel(name: 'New Name'); // id and bio are null
  patchModel.updatePatchUserEntity(patchEntity);
  print(
    '  ↳ Updated (ignoring nulls): id=${patchEntity.id}, name=${patchEntity.name}, bio=${patchEntity.bio}',
  );

  print('\n[Approach H] Hooks (Interception)');
  final hookedModel = HookedUserModel(id: 1, name: 'Bob');
  final hookedEntity = hookedModel.toEntity();
  print(
    '  ↳ Mapped with Hook: id=${hookedEntity.id}, mapped=${hookedEntity.mapped} (set by hook)',
  );
}
