import 'package:omni_mapper/omni_mapper.dart';

part 'extension_from.g.dart';

class EntityC {
  final int id;
  final String title;

  EntityC({
    required this.id,
    required this.title,
  });
}

// Approach C: Extension mapping FROM a source class
// Generates: extension EntityCToModel on EntityC { ModelC toModel() { ... } }
@OmniMapper(from: EntityC, methodName: 'toModel')
class ModelC {
  final int id;
  final String title;

  ModelC({
    required this.id,
    required this.title,
  });
}
