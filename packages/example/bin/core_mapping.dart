import 'package:example/core_mapping/abstract_class.dart';
import 'package:example/core_mapping/extension_from.dart';
import 'package:example/core_mapping/extension_to.dart';

void main() {
  print('\n🔵 Core Mapping');
  print('---------------------------------------------------');

  print('\n[Approach A] Abstract Class');
  final modelA = ModelA(id: 1, title: 'Item A');
  final mapperA = MapperAImpl();
  final entityA = mapperA.toEntity(modelA);
  print(
    '  ↳ Mapped ModelA to EntityA: id=${entityA.id}, title=${entityA.title}',
  );

  print('\n[Approach B] Extension TO target');
  final modelB = ModelB(id: 2, title: 'Item B');
  final entityB = modelB.toEntity();
  print(
    '  ↳ Mapped ModelB to EntityB: id=${entityB.id}, title=${entityB.title}',
  );

  print('\n[Approach C] Extension FROM source');
  final entityC = EntityC(id: 3, title: 'Item C');
  final modelC = entityC.toModel();
  print('  ↳ Mapped EntityC to ModelC: id=${modelC.id}, title=${modelC.title}');
}
