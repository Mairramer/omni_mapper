import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(
  r'''
extension ClearAndAddAllSourceToEntity on ClearAndAddAllSource {
  ClearAndAddAllTarget toEntity() {
    return ClearAndAddAllTarget(
      listField: listField,
      setField: setField,
      mapField: mapField,
    );
  }

  void updateClearAndAddAllTarget(ClearAndAddAllTarget target) {
    target.listField.clear();
    target.listField.addAll(listField);
    target.setField.clear();
    target.setField.addAll(setField);
    target.mapField.clear();
    target.mapField.addAll(mapField);
  }
}

extension ClearAndAddAllSourceToEntityList on Iterable<ClearAndAddAllSource> {
  List<ClearAndAddAllTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''',
)
@OmniMapper(
  target: ClearAndAddAllTarget,
  generateUpdateMethod: true,
  collectionUpdateStrategy: CollectionUpdateStrategy.clearAndAddAll,
)
class ClearAndAddAllSource {
  final List<String> listField;
  final Set<int> setField;
  final Map<String, dynamic> mapField;

  ClearAndAddAllSource({
    required this.listField,
    required this.setField,
    required this.mapField,
  });
}

class ClearAndAddAllTarget {
  final List<String> listField;
  final Set<int> setField;
  final Map<String, dynamic> mapField;

  ClearAndAddAllTarget({
    required this.listField,
    required this.setField,
    required this.mapField,
  });
}

@ShouldGenerate(
  r'''
extension AppendSourceToEntity on AppendSource {
  AppendTarget toEntity() {
    return AppendTarget(
      listField: listField,
      setField: setField,
      mapField: mapField,
    );
  }

  void updateAppendTarget(AppendTarget target) {
    target.listField.addAll(listField);
    target.setField.addAll(setField);
    target.mapField.addAll(mapField);
  }
}

extension AppendSourceToEntityList on Iterable<AppendSource> {
  List<AppendTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''',
)
@OmniMapper(
  target: AppendTarget,
  generateUpdateMethod: true,
  collectionUpdateStrategy: CollectionUpdateStrategy.append,
)
class AppendSource {
  final List<String> listField;
  final Set<int> setField;
  final Map<String, dynamic> mapField;

  AppendSource({
    required this.listField,
    required this.setField,
    required this.mapField,
  });
}

class AppendTarget {
  final List<String> listField;
  final Set<int> setField;
  final Map<String, dynamic> mapField;

  AppendTarget({
    required this.listField,
    required this.setField,
    required this.mapField,
  });
}

@ShouldGenerate(
  r'''
extension MixedSourceToEntity on MixedSource {
  MixedTarget toEntity() {
    return MixedTarget(
      listField: listField,
      setField: setField,
      mapField: mapField,
    );
  }

  void updateMixedTarget(MixedTarget target) {
    target.listField = listField;
    target.setField.clear();
    target.setField.addAll(setField);
    target.mapField.addAll(mapField);
  }
}

extension MixedSourceToEntityList on Iterable<MixedSource> {
  List<MixedTarget> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''',
)
@OmniMapper(
  target: MixedTarget,
  generateUpdateMethod: true,
)
class MixedSource {
  final List<String> listField;
  
  @OmniField(collectionUpdateStrategy: CollectionUpdateStrategy.clearAndAddAll)
  final Set<int> setField;
  
  @OmniField(collectionUpdateStrategy: CollectionUpdateStrategy.append)
  final Map<String, dynamic> mapField;

  MixedSource({
    required this.listField,
    required this.setField,
    required this.mapField,
  });
}

class MixedTarget {
  List<String> listField;
  final Set<int> setField;
  final Map<String, dynamic> mapField;

  MixedTarget({
    required this.listField,
    required this.setField,
    required this.mapField,
  });
}
