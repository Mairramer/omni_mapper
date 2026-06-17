import 'package:omni_mapper/omni_mapper.dart';

part 'approach_e_update.g.dart';

class MutableEntity {
  int id;
  String name;
  bool isActive;

  MutableEntity({
    required this.id,
    required this.name,
    this.isActive = false,
  });
}

@OmniMapper(
  target: MutableEntity,
  generateUpdateMethod: true, // This is true by default, but we are making it explicit
)
class FormModel {
  final int id;
  final String name;
  final bool isActive;

  FormModel({
    required this.id,
    required this.name,
    required this.isActive,
  });
}
