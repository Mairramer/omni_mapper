// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_flattening.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension FlattenModelToEntity on FlattenModel {
  FlattenTarget toEntity() {
    return FlattenTarget(
      userAddressCityName: userAddress?.city?.name,
      profileSettingsThemeId: profile.settings.theme?.id,
    )..profileSettingsThemeMode = profile.settings.theme?.mode;
  }
}

extension FlattenModelToEntityList on Iterable<FlattenModel> {
  List<FlattenTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
