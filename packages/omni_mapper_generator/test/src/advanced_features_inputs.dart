import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

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
    return EntityD(
      id: userId,
      status: '"active"',
      createdAt: const StringDateConverter().convert(createdAt),
    );
  }
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

// --- APPROACH H (Ignore If Null) ---
class TargetH {
  int? id;
  String? name;
  TargetH({this.id, this.name});
}

@ShouldGenerate(r'''
extension ModelHToTargetH on ModelH {
  TargetH toTargetH() {
    return TargetH(id: id, name: name);
  }

  void updateTargetH(TargetH target) {
    if (id case final id?) {
      target.id = id;
    }
    target.name = name;
  }
}

extension ModelHToTargetHList on Iterable<ModelH> {
  List<TargetH> toTargetHList() {
    return map((e) => e.toTargetH()).toList();
  }
}
''')
@OmniMapper(target: TargetH, generateUpdateMethod: true, ignoreIfNull: true, methodName: 'toTargetH')
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
    const MyHook().before(this);
    final target = TargetI(id: id);
    const MyHook().after(this, target);
    return target;
  }
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
    return TargetJ(
      status: TargetEnum.values.byName(status.name),
      optionalStatus: optionalStatus != null
          ? TargetEnum.values.byName((optionalStatus)!.name)
          : null,
    );
  }

  void updateTargetJ(TargetJ target) {
    target.status = TargetEnum.values.byName(status.name);
    target.optionalStatus = optionalStatus != null
        ? TargetEnum.values.byName((optionalStatus)!.name)
        : null;
  }
}

extension ModelJToTargetJList on Iterable<ModelJ> {
  List<TargetJ> toTargetJList() {
    return map((e) => e.toTargetJ()).toList();
  }
}
''')
@OmniMapper(target: TargetJ, generateUpdateMethod: true, methodName: 'toTargetJ')
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
    return TargetK(
      userAddressCityName: userAddress?.city?.name,
      profileSettingsThemeId: profile.settings.theme?.id,
    )..profileSettingsThemeMode = profile.settings.theme?.mode;
  }

  void updateTargetK(TargetK target) {
    target.profileSettingsThemeMode = profile.settings.theme?.mode;
  }
}

extension ModelKToTargetKList on Iterable<ModelK> {
  List<TargetK> toTargetKList() {
    return map((e) => e.toTargetK()).toList();
  }
}
''')
@OmniMapper(target: TargetK, generateUpdateMethod: true, methodName: 'toTargetK')
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
    return TargetL(id: userId, title: title, status: '"active"');
  }
}

extension ModelLToTargetLList on Iterable<ModelL> {
  List<TargetL> toTargetLList() {
    return map((e) => e.toTargetL()).toList();
  }
}

extension TargetLToModelL on TargetL {
  ModelL toModelL() {
    return ModelL(userId: id, title: title);
  }
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

// --- APPROACH M (MappingRule) ---
class TargetM {
  final String fullName;
  final int id;
  final String status;
  final String? ignoredField;

  TargetM({
    required this.fullName,
    required this.id,
    required this.status,
    this.ignoredField,
  });
}

@ShouldGenerate(r'''
extension ModelMToTargetM on ModelM {
  TargetM toTargetM() {
    return TargetM(
      fullName: firstName + ' ' + lastName,
      id: userId,
      status: '"active"',
    );
  }
}

extension ModelMToTargetMList on Iterable<ModelM> {
  List<TargetM> toTargetMList() {
    return map((e) => e.toTargetM()).toList();
  }
}
''')
@OmniMapper(
  target: TargetM,
  methodName: 'toTargetM',
  mappings: [
    MappingRule('fullName', custom: "firstName + ' ' + lastName"),
    MappingRule('id', source: 'userId'),
    MappingRule('status', defaultValue: '"active"'),
    MappingRule('ignoredField', ignore: true),
  ],
)
class ModelM {
  final String firstName;
  final String lastName;
  final int userId;

  ModelM({
    required this.firstName,
    required this.lastName,
    required this.userId,
  });
}

// -----------------------------------------------------------------------------
// APPROACH N: Polymorphic Subclass Mapping (Abstract Class)
// -----------------------------------------------------------------------------

class Vehicle {
  final int wheels;
  Vehicle(this.wheels);
}

class Car extends Vehicle {
  final int doors;
  Car(super.wheels, this.doors);
}

class Motorcycle extends Vehicle {
  final bool hasSidecar;
  Motorcycle(super.wheels, this.hasSidecar);
}

class VehicleEntity {
  final int wheels;
  VehicleEntity(this.wheels);
}

class CarEntity extends VehicleEntity {
  final int doors;
  CarEntity(super.wheels, this.doors);
}

class MotorcycleEntity extends VehicleEntity {
  final bool hasSidecar;
  MotorcycleEntity(super.wheels, this.hasSidecar);
}

@ShouldGenerate(r'''
class VehicleMapperImpl extends VehicleMapper {
  VehicleMapperImpl();

  @override
  VehicleEntity toEntity(Vehicle vehicle) {
    return switch (vehicle) {
      final Car s => carToEntity(s),
      final Motorcycle s => motoToEntity(s),
      _ => VehicleEntity(vehicle.wheels),
    };
  }

  @override
  CarEntity carToEntity(Car car) {
    return CarEntity(car.wheels, car.doors);
  }

  @override
  MotorcycleEntity motoToEntity(Motorcycle moto) {
    return MotorcycleEntity(moto.wheels, moto.hasSidecar);
  }
}
''')
@OmniMapper()
abstract class VehicleMapper {
  @SubclassMapping(source: Car, target: CarEntity)
  @SubclassMapping(source: Motorcycle, target: MotorcycleEntity)
  VehicleEntity toEntity(Vehicle vehicle);

  CarEntity carToEntity(Car car);
  MotorcycleEntity motoToEntity(Motorcycle moto);
}

// -----------------------------------------------------------------------------
// APPROACH O: Polymorphic Subclass Mapping (Extension)
// -----------------------------------------------------------------------------

@ShouldGenerate(r'''
extension VehicleBaseToEntity on VehicleBase {
  VehicleEntity toEntity() {
    return switch (this) {
      final CarBase s => s.toCarEntity(),
      final MotorcycleBase s => s.toMotorcycleEntity(),
      _ => VehicleEntity(wheels),
    };
  }
}

extension VehicleBaseToEntityList on Iterable<VehicleBase> {
  List<VehicleEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(
  target: VehicleEntity,
  subclasses: [
    SubclassMapping(
      source: CarBase,
      target: CarEntity,
      methodName: 'toCarEntity',
    ),
    SubclassMapping(source: MotorcycleBase, target: MotorcycleEntity),
  ],
)
class VehicleBase {
  final int wheels;
  VehicleBase(this.wheels);
}

class CarBase extends VehicleBase {
  CarBase(super.wheels);
}

class MotorcycleBase extends VehicleBase {
  MotorcycleBase(super.wheels);
}

// -----------------------------------------------------------------------------
// APPROACH P: Abstract Target Fallback Exception
// -----------------------------------------------------------------------------

abstract class AbstractTarget {}

@ShouldGenerate(r'''
class AbstractTargetMapperImpl extends AbstractTargetMapper {
  AbstractTargetMapperImpl();

  @override
  AbstractTarget toTarget(VehicleBase source) {
    throw UnsupportedError(
      'Cannot instantiate abstract class AbstractTarget. Did you forget to map all subclasses?',
    );
  }
}
''')
@OmniMapper()
abstract class AbstractTargetMapper {
  AbstractTarget toTarget(VehicleBase source);
}

// -----------------------------------------------------------------------------
// APPROACH Q: Hooks with optimization disabled
// -----------------------------------------------------------------------------

class HookTarget {
  final int id;
  HookTarget(this.id);
}

class DummyHook extends OmniHook<DummyModel, HookTarget> {
  @override
  void before(DummyModel source) {}
  @override
  void after(DummyModel source, HookTarget target) {}
}

@ShouldGenerate(r'''
extension DummyModelToHookTarget on DummyModel {
  HookTarget toHookTarget() {
    const DummyHook().before(this);
    final target = HookTarget(id);
    const DummyHook().after(this, target);
    return target;
  }
}

extension DummyModelToHookTargetList on Iterable<DummyModel> {
  List<HookTarget> toHookTargetList() {
    return map((e) => e.toHookTarget()).toList();
  }
}
''')
@OmniMapper(target: HookTarget, hook: DummyHook, methodName: 'toHookTarget')
class DummyModel {
  final int id;
  DummyModel(this.id);
}

// --- Nested Target Shadowing Update Method Test ---
class NestedTargetShadowModel {
  final String val;
  NestedTargetShadowModel(this.val);
}

class TargetShadowTarget {
  String val;
  TargetShadowTarget(this.val);
}

@ShouldGenerate(r'''
extension TargetShadowSourceToEntity on TargetShadowSource {
  TargetShadowTarget toEntity() {
    return TargetShadowTarget(target.val);
  }

  void updateTargetShadowTarget(TargetShadowTarget target) {
    target.val = this.target.val;
  }
}

extension TargetShadowSourceToEntityList on Iterable<TargetShadowSource> {
  List<TargetShadowTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(
  target: TargetShadowTarget,
  generateUpdateMethod: true,
  mappings: [
    MappingRule('val', source: 'target.val'),
  ],
)
class TargetShadowSource {
  final NestedTargetShadowModel target;
  TargetShadowSource(this.target);
}
