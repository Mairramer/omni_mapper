import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

// --- APPROACH A ---
class EntityA {
  final int id;
  final String title;
  EntityA({required this.id, required this.title});
}

class ModelA {
  final int id;
  final String title;
  ModelA({required this.id, required this.title});
}

@ShouldGenerate(r'''
class MapperAImpl extends MapperA {
  @override
  EntityA toEntity(ModelA model) {
    final target = EntityA(id: model.id, title: model.title);
    return target;
  }
}
''')
@OmniMapper()
abstract class MapperA {
  EntityA toEntity(ModelA model);
}

// --- APPROACH B ---
class EntityB {
  final int id;
  final String title;
  EntityB({required this.id, required this.title});
}

@ShouldGenerate(r'''
extension ModelBToEntity on ModelB {
  EntityB toEntity() {
    final target = EntityB(id: id, title: title);
    return target;
  }

  void updateEntityB(EntityB target) {}
}

extension ModelBToEntityList on Iterable<ModelB> {
  List<EntityB> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(target: EntityB)
class ModelB {
  final int id;
  final String title;
  ModelB({required this.id, required this.title});
}

// --- APPROACH C ---
class EntityC {
  final int id;
  final String title;
  EntityC({required this.id, required this.title});
}

@ShouldGenerate(r'''
extension EntityCToModel on EntityC {
  ModelC toModel() {
    final target = ModelC(id: id, title: title);
    return target;
  }

  void updateModelC(ModelC target) {}
}

extension EntityCToModelList on Iterable<EntityC> {
  List<ModelC> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
''')
@OmniMapper(from: EntityC, methodName: 'toModel')
class ModelC {
  final int id;
  final String title;
  ModelC({required this.id, required this.title});
}

// --- APPROACH D (Advanced Features) ---
class EntityD {
  final int id;
  final String status;
  final DateTime createdAt;
  EntityD({required this.id, required this.status, required this.createdAt});
}

class StringDateConverter extends OmniConverter<String, DateTime> {
  const StringDateConverter();
  @override
  DateTime convert(String source) => DateTime.parse(source);
}

@ShouldGenerate(r'''
extension ModelDToEntity on ModelD {
  EntityD toEntity() {
    final target = EntityD(
      id: userId,
      status: "active",
      createdAt: const StringDateConverter().convert(createdAt),
    );
    return target;
  }

  void updateEntityD(EntityD target) {}
}

extension ModelDToEntityList on Iterable<ModelD> {
  List<EntityD> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(
  target: EntityD,
  fieldMaps: {'userId': 'id'},
  defaultValues: {'status': '"active"'},
  converters: [StringDateConverter],
)
class ModelD {
  final int userId;
  final String createdAt;
  ModelD({required this.userId, required this.createdAt});
}

// --- APPROACH E (In-Place Update) ---
class MutableEntityE {
  int id;
  String name;
  MutableEntityE({required this.id, required this.name});
}

@ShouldGenerate(r'''
extension ModelEToMutableEntityE on ModelE {
  MutableEntityE toMutableEntityE() {
    final target = MutableEntityE(id: id, name: name);
    return target;
  }

  void updateMutableEntityE(MutableEntityE target) {
    target.id = this.id;
    target.name = this.name;
  }
}

extension ModelEToMutableEntityEList on Iterable<ModelE> {
  List<MutableEntityE> toMutableEntityEList() {
    return map((e) => e.toMutableEntityE()).toList();
  }
}
''')
@OmniMapper(target: MutableEntityE, methodName: 'toMutableEntityE')
class ModelE {
  final int id;
  final String name;
  ModelE({required this.id, required this.name});
}

// --- ERROR SCENARIOS ---
@ShouldThrow(
  '`@OmniMapper` on a concrete class must specify a `target` or `from` type.',
)
@OmniMapper()
class InvalidConcreteClass {
  final int id;
  InvalidConcreteClass({required this.id});
}

// --- APPROACH F (Strict Mode - Success with Initializer & Default) ---
class TargetF {
  final int id;
  final int rating;
  int count = 0; // has initializer

  TargetF({required this.id, this.rating = 5}); // rating has default value
}

@ShouldGenerate(r'''
extension ModelFToTargetF on ModelF {
  TargetF toTargetF() {
    final target = TargetF(id: id);
    return target;
  }

  void updateTargetF(TargetF target) {}
}

extension ModelFToTargetFList on Iterable<ModelF> {
  List<TargetF> toTargetFList() {
    return map((e) => e.toTargetF()).toList();
  }
}
''')
@OmniMapper(target: TargetF, strictMode: true, methodName: 'toTargetF')
class ModelF {
  final int id;
  ModelF({required this.id});
}

// --- APPROACH G (Strict Mode - Error) ---
class TargetG {
  final int id;
  String? unmapped;
  TargetG({required this.id});
}

@ShouldThrow(
  'Strict mode is enabled, but the following target properties are unmapped: unmapped.\n'
  'To fix this, map them from the source, provide a defaultValue, or add them to ignoreFields.',
)
@OmniMapper(target: TargetG, strictMode: true, methodName: 'toTargetG')
class ModelG {
  final int id;
  ModelG({required this.id});
}

// --- APPROACH H (Ignore If Null) ---
class TargetH {
  int? id;
  String? name;
  TargetH({this.id, this.name});
}

@ShouldGenerate(r'''
extension ModelHToTargetH on ModelH {
  TargetH toTargetH() {
    final target = TargetH(id: id, name: name);
    return target;
  }

  void updateTargetH(TargetH target) {
    if (this.id case final id?) target.id = id;
    target.name = this.name;
  }
}

extension ModelHToTargetHList on Iterable<ModelH> {
  List<TargetH> toTargetHList() {
    return map((e) => e.toTargetH()).toList();
  }
}
''')
@OmniMapper(target: TargetH, ignoreIfNull: true, methodName: 'toTargetH')
class ModelH {
  final int? id; // Nullable
  final String name; // Non-nullable
  ModelH({this.id, required this.name});
}

// --- APPROACH I (Hooks) ---
class TargetI {
  final int id;
  TargetI({required this.id});
}

class MyHook extends OmniHook<ModelI, TargetI> {
  const MyHook();
  @override
  void before(ModelI source) {}
  @override
  void after(ModelI source, TargetI target) {}
}

@ShouldGenerate(r'''
extension ModelIToTargetI on ModelI {
  TargetI toTargetI() {
    MyHook().before(this);
    final target = TargetI(id: id);
    MyHook().after(this, target);
    return target;
  }

  void updateTargetI(TargetI target) {}
}

extension ModelIToTargetIList on Iterable<ModelI> {
  List<TargetI> toTargetIList() {
    return map((e) => e.toTargetI()).toList();
  }
}
''')
@OmniMapper(target: TargetI, hook: MyHook, methodName: 'toTargetI')
class ModelI {
  final int id;
  ModelI({required this.id});
}

// --- APPROACH J (Enum Mapping) ---
enum SourceEnum { active, inactive }

enum TargetEnum { active, inactive, unknown }

class TargetJ {
  TargetEnum status;
  TargetEnum? optionalStatus;
  TargetJ({required this.status, this.optionalStatus});
}

@ShouldGenerate(r'''
extension ModelJToTargetJ on ModelJ {
  TargetJ toTargetJ() {
    final target = TargetJ(
      status: TargetEnum.values.byName(status.name),
      optionalStatus: optionalStatus != null
          ? TargetEnum.values.byName((optionalStatus)!.name)
          : null,
    );
    return target;
  }

  void updateTargetJ(TargetJ target) {
    target.status = TargetEnum.values.byName(this.status.name);
    target.optionalStatus = this.optionalStatus != null
        ? TargetEnum.values.byName((this.optionalStatus)!.name)
        : null;
  }
}

extension ModelJToTargetJList on Iterable<ModelJ> {
  List<TargetJ> toTargetJList() {
    return map((e) => e.toTargetJ()).toList();
  }
}
''')
@OmniMapper(target: TargetJ, methodName: 'toTargetJ')
class ModelJ {
  final SourceEnum status;
  final SourceEnum? optionalStatus;
  ModelJ({required this.status, this.optionalStatus});
}

// --- APPROACH K (Auto-Flattening) ---
class TargetK {
  final String? userAddressCityName;
  final String? profileSettingsThemeId;
  String? profileSettingsThemeMode;

  TargetK({
    this.userAddressCityName,
    this.profileSettingsThemeId,
  });
}

class CityK {
  final String name;
  CityK({required this.name});
}

class AddressK {
  final CityK? city;
  AddressK({this.city});
}

class ThemeK {
  final String id;
  final String mode;
  ThemeK({required this.id, required this.mode});
}

class SettingsK {
  final ThemeK? theme;
  SettingsK({this.theme});
}

class ProfileK {
  final SettingsK settings;
  ProfileK({required this.settings});
}

@ShouldGenerate(r'''
extension ModelKToTargetK on ModelK {
  TargetK toTargetK() {
    final target = TargetK(
      userAddressCityName: this.userAddress?.city?.name,
      profileSettingsThemeId: this.profile.settings.theme?.id,
    )..profileSettingsThemeMode = this.profile.settings.theme?.mode;
    return target;
  }

  void updateTargetK(TargetK target) {
    target.profileSettingsThemeMode = this.profile.settings.theme?.mode;
  }
}

extension ModelKToTargetKList on Iterable<ModelK> {
  List<TargetK> toTargetKList() {
    return map((e) => e.toTargetK()).toList();
  }
}
''')
@OmniMapper(target: TargetK, methodName: 'toTargetK')
class ModelK {
  final AddressK? userAddress;
  final ProfileK profile;

  ModelK({this.userAddress, required this.profile});
}

// --- APPROACH L (Reverse Mapping) ---
class TargetL {
  final int id;
  final String title;
  final String status;
  TargetL({required this.id, required this.title, required this.status});
}

@ShouldGenerate(r'''
extension ModelLToTargetL on ModelL {
  TargetL toTargetL() {
    final target = TargetL(id: userId, title: title, status: "active");
    return target;
  }

  void updateTargetL(TargetL target) {}
}

extension ModelLToTargetLList on Iterable<ModelL> {
  List<TargetL> toTargetLList() {
    return map((e) => e.toTargetL()).toList();
  }
}

extension TargetLToModelL on TargetL {
  ModelL toModelL() {
    final target = ModelL(userId: id, title: title);
    return target;
  }

  void updateModelL(ModelL target) {}
}

extension TargetLToModelLList on Iterable<TargetL> {
  List<ModelL> toModelLList() {
    return map((e) => e.toModelL()).toList();
  }
}
''')
@OmniMapper(
  target: TargetL,
  methodName: 'toTargetL',
  generateReverse: true,
  reverseMethodName: 'toModelL',
  fieldMaps: {'userId': 'id'},
  defaultValues: {'status': '"active"'},
)
class ModelL {
  final int userId;
  final String title;
  ModelL({required this.userId, required this.title});
}

// --- FEATURE 1: Multiple Sources ---
class SourceX {
  final int id;
  SourceX({required this.id});
}

class SourceY {
  final String name;
  SourceY({required this.name});
}

class TargetMultiple {
  final int id;
  final String name;
  TargetMultiple({required this.id, required this.name});
}

@ShouldGenerate(r'''
class MultipleSourcesMapperImpl extends MultipleSourcesMapper {
  @override
  TargetMultiple toTarget(SourceX x, SourceY y) {
    final target = TargetMultiple(id: x.id, name: y.name);
    return target;
  }
}
''')
@OmniMapper()
abstract class MultipleSourcesMapper {
  TargetMultiple toTarget(SourceX x, SourceY y);
}

// --- FEATURE 7: Factory Constructors (Freezed) ---
class FreezedLikeModel {
  final String title;
  FreezedLikeModel._(this.title);

  factory FreezedLikeModel({required String title}) {
    return FreezedLikeModel._(title);
  }
}

class SourceFreezed {
  final String title;
  SourceFreezed({required this.title});
}

@ShouldGenerate(r'''
class FreezedMapperImpl extends FreezedMapper {
  @override
  FreezedLikeModel toFreezed(SourceFreezed source) {
    final target = FreezedLikeModel(title: source.title);
    return target;
  }
}
''')
@OmniMapper()
abstract class FreezedMapper {
  FreezedLikeModel toFreezed(SourceFreezed source);
}
