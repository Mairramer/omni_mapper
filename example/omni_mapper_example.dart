import 'package:example/approach_a_abstract_class.dart';
import 'package:example/approach_b_extension_to.dart';
import 'package:example/approach_c_extension_from.dart';

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
}
