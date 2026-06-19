import 'package:example/strict_mode/strict_validation.dart';

void main() {
  print('\n🔵 Strict Mode Verification');
  print('---------------------------------------------------');

  print('\n[Approach F] Strict Mode Validation');
  final strictModel = StrictUserModel(id: 1, name: 'Alice');
  final strictEntity = strictModel.toEntity();
  print(
    '  ↳ id=${strictEntity.id}, name=${strictEntity.name}, unmappedField=${strictEntity.unmappedField}',
  );
  print(
    '  ↳ Strict mode ensured that `unmappedField` was either mapped, defaulted, or ignored at compile time!',
  );
}
