import 'package:omni_mapper/omni_mapper.dart';

part 'approach_g_ignore_if_null.g.dart';

class PatchUserEntity {
  int id;
  String name;
  String bio;

  PatchUserEntity({
    required this.id,
    required this.name,
    required this.bio,
  });
}

// In a PATCH request, we only want to update fields that are provided (not null).
@OmniMapper(
  target: PatchUserEntity,
  ignoreIfNull: true,
)
class PatchUserModel {
  final int? id;
  final String? name;
  final String? bio;

  PatchUserModel({this.id, this.name, this.bio});
}
