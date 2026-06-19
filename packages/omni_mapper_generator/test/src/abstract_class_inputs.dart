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
  MapperAImpl.new() : super();

  @override
  EntityA toEntity(ModelA model) {
    return EntityA(id: model.id, title: model.title);
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
  MultipleSourcesMapperImpl.new() : super();

  @override
  TargetMultiple toTarget(SourceX x, SourceY y) {
    return TargetMultiple(id: x.id, name: y.name);
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
  FreezedMapperImpl.new() : super();

  @override
  FreezedLikeModel toFreezed(SourceFreezed source) {
    return FreezedLikeModel(title: source.title);
  }
}
''')
@OmniMapper()
abstract class FreezedMapper {
  FreezedLikeModel toFreezed(SourceFreezed source);
}
