// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abstract_class.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class MapperAImpl extends MapperA {
  MapperAImpl.new() : super();

  @override
  EntityA toEntity(ModelA model) {
    return EntityA(
      id: model.id,
      title: model.title,
    );
  }
}
