import 'package:omni_mapper/omni_mapper.dart';

part 'mapping_rules.g.dart';

class TargetRule {
  final String fullName;
  final int id;
  final String status;
  final String? ignoredField;

  TargetRule({
    required this.fullName,
    required this.id,
    required this.status,
    this.ignoredField,
  });
}

@OmniMapper(
  target: TargetRule,
  methodName: 'toTargetRule',
  mappings: [
    MappingRule('fullName', custom: r"'$firstName $lastName'"),
    MappingRule('id', source: 'userId'),
    MappingRule('status', defaultValue: 'active'),
    MappingRule('ignoredField', ignore: true),
  ],
)
class ModelRule {
  final String firstName;
  final String lastName;
  final int userId;

  ModelRule({
    required this.firstName,
    required this.lastName,
    required this.userId,
  });
}
