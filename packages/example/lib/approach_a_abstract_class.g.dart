// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_a_abstract_class.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class MapperAImpl extends MapperA {
  @override
  EntityA toEntity(ModelA model) {
    final target = EntityA(
      id: model.id,
      title: model.title,
    );
    return target;
  }
}
