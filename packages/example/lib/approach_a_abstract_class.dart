import 'package:omni_mapper/omni_mapper.dart';

part 'approach_a_abstract_class.g.dart';

class EntityA {
  final int id;
  final String title;

  EntityA({
    required this.id,
    required this.title,
  });
}

class ModelA {
  final int id;
  final String title;

  ModelA({
    required this.id,
    required this.title,
  });
}

// Approach A: Centralized Abstract Class Mapper
@OmniMapper()
abstract class MapperA {
  EntityA toEntity(ModelA model);
}
