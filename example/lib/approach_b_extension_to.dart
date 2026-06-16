import 'package:omni_mapper/omni_mapper.dart';

part 'approach_b_extension_to.g.dart';

class EntityB {
  final int id;
  final String title;

  EntityB({
    required this.id,
    required this.title,
  });
}

// Approach B: Extension mapping TO a target class
// Generates: extension ModelBToEntity on ModelB { EntityB toEntity() { ... } }
@OmniMapper(target: EntityB)
class ModelB {
  final int id;
  final String title;

  ModelB({
    required this.id,
    required this.title,
  });
}
