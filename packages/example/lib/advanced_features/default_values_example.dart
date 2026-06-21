import 'package:omni_mapper/omni_mapper.dart';

part 'default_values_example.g.dart';

enum DeviceType { ios, android, web }

class DeviceDto {
  final String deviceId;

  DeviceDto({required this.deviceId});
}

class DeviceEntity {
  final String deviceId;
  final DeviceType type;
  final bool isActive;
  final int loginCount;
  final double version;

  DeviceEntity({
    required this.deviceId,
    required this.type,
    required this.isActive,
    required this.loginCount,
    required this.version,
  });
}

@OmniMapper(
  target: DeviceEntity,
  mappings: [
    MappingRule('type', defaultValue: DeviceType.web),
    MappingRule('isActive', defaultValue: true),
    MappingRule('loginCount', defaultValue: 0),
    MappingRule('version', defaultValue: 1.0),
  ],
)
class DeviceModel {
  final String deviceId;

  DeviceModel({required this.deviceId});
}

// --- Complex Object Default Value Example ---

class CustomConfig {
  final String theme;
  final bool enableNotifications;

  const CustomConfig({required this.theme, required this.enableNotifications});
}

class AppStateEntity {
  final int userId;
  final CustomConfig config;

  AppStateEntity({
    required this.userId,
    required this.config,
  });
}

@OmniMapper(
  target: AppStateEntity,
  mappings: [
    // Provide a literal primitive object (e.g., int, bool, double, Enum)
    // and it will be mapped correctly without needing string evaluation.
    MappingRule('userId', custom: 999),

    // For complex objects, you STILL need to use 'custom' to provide the raw Dart code string
    MappingRule(
      'config',
      custom: CustomConfig(theme: 'dark', enableNotifications: true),
    ),
  ],
)
class AppStateModel {
  AppStateModel();
}
