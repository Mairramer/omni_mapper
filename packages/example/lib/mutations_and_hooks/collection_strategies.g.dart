// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_strategies.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension ConfigUpdatePayloadToEntity on ConfigUpdatePayload {
  SystemConfig toEntity() {
    return SystemConfig(
      environmentVars: environmentVars,
      activeRoles: activeRoles,
      errorLogs: errorLogs,
    );
  }

  void updateSystemConfig(SystemConfig target) {
    target.environmentVars.addAll(environmentVars);
    target.activeRoles.clear();
    target.activeRoles.addAll(activeRoles);
    target.errorLogs.addAll(errorLogs);
  }
}

extension ConfigUpdatePayloadToEntityList on Iterable<ConfigUpdatePayload> {
  List<SystemConfig> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
