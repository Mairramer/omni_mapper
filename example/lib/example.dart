import 'package:omni_mapper/omni_mapper.dart';

part 'example.g.dart';

class UserEntity {
  final int id;
  final String name;

  UserEntity({required this.id, required this.name});
}

@OmniMapper(target: UserEntity)
class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});
}
