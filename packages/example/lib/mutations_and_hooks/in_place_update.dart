import 'package:omni_mapper/omni_mapper.dart';

part 'in_place_update.g.dart';

class MutableEntity {
  int id;
  String name;
  bool isActive;
  List<String> tags;

  MutableEntity({
    required this.id,
    required this.name,
    this.isActive = false,
    this.tags = const [],
  });
}

@OmniMapper(
  target: MutableEntity,
  generateUpdateMethod: true,
  collectionUpdateStrategy: CollectionUpdateStrategy.clearAndAddAll,
)
class FormModel {
  final int id;
  final String name;
  final bool isActive;
  final List<String> tags;

  FormModel({
    required this.id,
    required this.name,
    required this.isActive,
    this.tags = const [],
  });
}
