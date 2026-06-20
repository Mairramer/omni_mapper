// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_values_example.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension DeviceModelToEntity on DeviceModel {
  DeviceEntity toEntity() {
    return DeviceEntity(
      deviceId: deviceId,
      type: DeviceType.web,
      isActive: true,
      loginCount: 0,
      version: 1.0,
    );
  }

  void updateDeviceEntity(DeviceEntity target) {}
}

extension DeviceModelToEntityList on Iterable<DeviceModel> {
  List<DeviceEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}

extension AppStateModelToEntity on AppStateModel {
  AppStateEntity toEntity() {
    return AppStateEntity(
      userId: 999,
      config: const CustomConfig(theme: 'dark', enableNotifications: true),
    );
  }

  void updateAppStateEntity(AppStateEntity target) {}
}

extension AppStateModelToEntityList on Iterable<AppStateModel> {
  List<AppStateEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
