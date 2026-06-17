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
