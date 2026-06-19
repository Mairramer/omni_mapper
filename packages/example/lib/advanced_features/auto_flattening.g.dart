// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_flattening.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension FlattenModelToEntity on FlattenModel {
  FlattenTarget toEntity() {
    final target = FlattenTarget(
      userAddressCityName: this.userAddress?.city?.name,
      profileSettingsThemeId: this.profile.settings.theme?.id,
    )..profileSettingsThemeMode = this.profile.settings.theme?.mode;
    return target;
  }

  void updateFlattenTarget(FlattenTarget target) {
    target.profileSettingsThemeMode = this.profile.settings.theme?.mode;
  }
}

extension FlattenModelToEntityList on Iterable<FlattenModel> {
  List<FlattenTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
