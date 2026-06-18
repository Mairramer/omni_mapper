import 'package:omni_mapper/omni_mapper.dart';

part 'approach_f_strict_mode.g.dart';

class StrictUserEntity {
  final int id;
  final String name;
  final String?
  unmappedField; // optional, so it doesn't fail the required check

  StrictUserEntity({
    required this.id,
    required this.name,
    this.unmappedField,
  });
}

// Without strictMode: true, omitting unmappedField would just fail compilation silently
// because unmappedField is required, but if it wasn't required it would silently be null.
// With strictMode: true, it throws a generation error if we don't map it or ignore it.
@OmniMapper(
  target: StrictUserEntity,
  strictMode: true,
  ignoreFields: [
    'unmappedField',
  ], // We must ignore it or map it to prevent generation error
)
class StrictUserModel {
  final int id;
  final String name;

  StrictUserModel({required this.id, required this.name});
}
