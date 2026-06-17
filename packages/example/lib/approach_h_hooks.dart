import 'package:omni_mapper/omni_mapper.dart';

part 'approach_h_hooks.g.dart';

class HookedUserEntity {
  final int id;
  final String name;
  bool mapped;

  HookedUserEntity({
    required this.id,
    required this.name,
    this.mapped = false,
  });
}

class HookedUserMapperHook extends OmniHook<HookedUserModel, HookedUserEntity> {
  const HookedUserMapperHook();

  @override
  void before(HookedUserModel source) {
    print('Starting mapping for ${source.name}');
  }

  @override
  void after(HookedUserModel source, HookedUserEntity target) {
    target.mapped = true;
    print('Finished mapping for ${source.name}');
  }
}

@OmniMapper(
  target: HookedUserEntity,
  hook: HookedUserMapperHook,
)
class HookedUserModel {
  final int id;
  final String name;

  HookedUserModel({required this.id, required this.name});
}
