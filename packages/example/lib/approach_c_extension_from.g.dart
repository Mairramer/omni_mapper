// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_c_extension_from.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension EntityCToModel on EntityC {
  ModelC toModel() {
    final target = ModelC(
      id: id,
      title: title,
    );
    return target;
  }

  void updateModelC(ModelC target) {}
}

extension EntityCToModelList on Iterable<EntityC> {
  List<ModelC> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
