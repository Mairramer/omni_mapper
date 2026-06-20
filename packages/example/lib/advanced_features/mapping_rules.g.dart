// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapping_rules.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension ModelRuleToTargetRule on ModelRule {
  TargetRule toTargetRule() {
    return TargetRule(
      fullName: '$firstName $lastName',
      id: userId,
      status: 'active',
    );
  }

  void updateTargetRule(TargetRule target) {}
}

extension ModelRuleToTargetRuleList on Iterable<ModelRule> {
  List<TargetRule> toTargetRuleList() {
    return map((e) => e.toTargetRule()).toList();
  }
}
