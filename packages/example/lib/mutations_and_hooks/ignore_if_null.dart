import 'package:omni_mapper/omni_mapper.dart';

part 'ignore_if_null.g.dart';

class PatchUserEntity {
  int? id;
  String? name;
  String? bio;

  PatchUserEntity({
    this.id,
    this.name,
    this.bio,
  });
}

// In a PATCH request, we only want to update fields that are provided (not null).
@OmniMapper(
  target: PatchUserEntity,
  ignoreIfNull: true,
  generateUpdateMethod: true,
)
class PatchUserModel {
  final int? id;
  final String? name;
  final String? bio;

  PatchUserModel({this.id, this.name, this.bio});
}
