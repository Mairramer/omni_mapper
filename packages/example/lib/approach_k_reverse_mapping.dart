import 'package:omni_mapper/omni_mapper.dart';

part 'approach_k_reverse_mapping.g.dart';

class DtoModel {
  final String id;
  final String name;
  final int age;
  final String status;

  const DtoModel({
    required this.id,
    required this.name,
    required this.age,
    required this.status,
  });
}

@OmniMapper(
  target: DtoModel,
  methodName: 'toDto',
  generateReverse: true,
  reverseMethodName: 'toEntity',
  fieldMaps: {'userId': 'id', 'fullName': 'name'},
  defaultValues: {'status': '"active"'}, // default values are ignored in reverse
)
class EntityModel {
  final String userId;
  final String fullName;
  final int age;

  const EntityModel({
    required this.userId,
    required this.fullName,
    required this.age,
  });
}
