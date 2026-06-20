// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_from.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension EntityCToModel on EntityC {
  ModelC toModel() {
    return ModelC(
      id: id,
      title: title,
    );
  }
}

extension EntityCToModelList on Iterable<EntityC> {
  List<ModelC> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
