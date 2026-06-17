// ignore_for_file: depend_on_referenced_packages
import 'package:omni_mapper/omni_mapper.dart';

// --- Target class ---

class UserEntity {
  final int id;
  final String name;
  UserEntity({required this.id, required this.name});
}

// --- Annotated source class ---

// This annotation tells the omni_mapper_generator to generate
// an extension method `toEntity()` on `UserModel` that returns
// a `UserEntity`.
@OmniMapper(target: UserEntity)
class UserModel {
  final int id;
  final String name;
  UserModel({required this.id, required this.name});
}

// After running `dart run build_runner build`, use it like:
//
// void main() {
//   final model = UserModel(id: 1, name: 'John');
//   final entity = model.toEntity();
//   print(entity.name); // John
// }
