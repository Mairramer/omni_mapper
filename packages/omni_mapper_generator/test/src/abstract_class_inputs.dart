import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

// --- APPROACH A ---
class EntityA {
  final int id;
  final String title;
  EntityA({required this.id, required this.title});
}

class ModelA {
  final int id;
  final String title;
  ModelA({required this.id, required this.title});
}

@ShouldGenerate(r'''
class MapperAImpl extends MapperA {
  @override
  EntityA toEntity(ModelA model) {
    final target = EntityA(id: model.id, title: model.title);
    return target;
  }
}
''')
@OmniMapper()
abstract class MapperA {
  EntityA toEntity(ModelA model);
}

class SourceX {
  final int id;
  SourceX({required this.id});
}

class SourceY {
  final String name;
  SourceY({required this.name});
}

class TargetMultiple {
  final int id;
  final String name;
  TargetMultiple({required this.id, required this.name});
}

@ShouldGenerate(r'''
class MultipleSourcesMapperImpl extends MultipleSourcesMapper {
  @override
  TargetMultiple toTarget(SourceX x, SourceY y) {
    final target = TargetMultiple(id: x.id, name: y.name);
    return target;
  }
}
''')
@OmniMapper()
abstract class MultipleSourcesMapper {
  TargetMultiple toTarget(SourceX x, SourceY y);
}

class FreezedLikeModel {
  final String title;

  factory FreezedLikeModel({required String title}) {
    return FreezedLikeModel._(title);
  }
  FreezedLikeModel._(this.title);
}

class SourceFreezed {
  final String title;
  SourceFreezed({required this.title});
}

@ShouldGenerate(r'''
class FreezedMapperImpl extends FreezedMapper {
  @override
  FreezedLikeModel toFreezed(SourceFreezed source) {
    final target = FreezedLikeModel(title: source.title);
    return target;
  }
}
''')
@OmniMapper()
abstract class FreezedMapper {
  FreezedLikeModel toFreezed(SourceFreezed source);
}
