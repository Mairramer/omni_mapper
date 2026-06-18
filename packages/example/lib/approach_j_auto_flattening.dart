import 'package:omni_mapper/omni_mapper.dart';

part 'approach_j_auto_flattening.g.dart';

class FlattenTarget {
  final String? userAddressCityName;
  final String? profileSettingsThemeId;
  String? profileSettingsThemeMode;

  FlattenTarget({
    this.userAddressCityName,
    this.profileSettingsThemeId,
  });
}

class City {
  final String name;
  City({required this.name});
}

class Address {
  final City? city;
  Address({this.city});
}

class Theme {
  final String id;
  final String mode;
  Theme({required this.id, required this.mode});
}

class Settings {
  final Theme? theme;
  Settings({this.theme});
}

class Profile {
  final Settings settings;
  Profile({required this.settings});
}

@OmniMapper(target: FlattenTarget)
class FlattenModel {
  final Address? userAddress;
  final Profile profile;

  FlattenModel({this.userAddress, required this.profile});
}
