import 'package:omni_mapper/omni_mapper.dart';

part 'extension_to.g.dart';

class EntityB {
  final int id;
  final String title;

  EntityB({
    required this.id,
    required this.title,
  });
}

class EntityB2 {
  final int id;
  final String title;

  EntityB2({
    required this.id,
    required this.title,
  });
}

// Approach B: Extension mapping TO a target class
// Generates: extension ModelBToEntity on ModelB { EntityB toEntity() { ... } }
@OmniMappers([
  OmniMapper(target: EntityB),
  OmniMapper(target: EntityB2, methodName: 'toEntityB2'),
])
class ModelB {
  final int id;
  final String title;

  ModelB({
    required this.id,
    required this.title,
  });
}
