import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

// --- APPROACH B ---
class EntityB {
  final int id;
  final String title;
  EntityB({required this.id, required this.title});
}

@ShouldGenerate(r'''
extension ModelBToEntity on ModelB {
  EntityB toEntity() {
    return EntityB(id: id, title: title);
  }

  void updateEntityB(EntityB target) {}
}

extension ModelBToEntityList on Iterable<ModelB> {
  List<EntityB> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(target: EntityB)
class ModelB {
  final int id;
  final String title;
  ModelB({required this.id, required this.title});
}

// --- APPROACH C ---
class EntityC {
  final int id;
  final String title;
  EntityC({required this.id, required this.title});
}

@ShouldGenerate(r'''
extension EntityCToModel on EntityC {
  ModelC toModel() {
    return ModelC(id: id, title: title);
  }

  void updateModelC(ModelC target) {}
}

extension EntityCToModelList on Iterable<EntityC> {
  List<ModelC> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
''')
@OmniMapper(from: EntityC, methodName: 'toModel')
class ModelC {
  final int id;
  final String title;
  ModelC({required this.id, required this.title});
}

// --- APPROACH E (In-Place Update) ---
class MutableEntityE {
  int id;
  String name;
  MutableEntityE({required this.id, required this.name});
}

@ShouldGenerate(r'''
extension ModelEToMutableEntityE on ModelE {
  MutableEntityE toMutableEntityE() {
    return MutableEntityE(id: id, name: name);
  }

  void updateMutableEntityE(MutableEntityE target) {
    target.id = this.id;
    target.name = this.name;
  }
}

extension ModelEToMutableEntityEList on Iterable<ModelE> {
  List<MutableEntityE> toMutableEntityEList() {
    return map((e) => e.toMutableEntityE()).toList();
  }
}
''')
@OmniMapper(target: MutableEntityE, methodName: 'toMutableEntityE')
class ModelE {
  final int id;
  final String name;
  ModelE({required this.id, required this.name});
}
