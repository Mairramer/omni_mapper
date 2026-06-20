import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

// --- APPROACH A (Literal Default Values in Map) ---
class TargetA {
  final String status;
  final int count;
  final double ratio;
  final bool isValid;

  TargetA({
    required this.status,
    required this.count,
    required this.ratio,
    required this.isValid,
  });
}

@ShouldGenerate(r'''
extension ModelAToTargetA on ModelA {
  TargetA toTargetA() {
    return TargetA(status: 'active', count: 42, ratio: 3.14, isValid: true);
  }

  void updateTargetA(TargetA target) {}
}

extension ModelAToTargetAList on Iterable<ModelA> {
  List<TargetA> toTargetAList() {
    return map((e) => e.toTargetA()).toList();
  }
}
''')
@OmniMapper(
  target: TargetA,
  methodName: 'toTargetA',
  defaultValues: {
    'status': 'active',
    'count': 42,
    'ratio': 3.14,
    'isValid': true,
  },
)
class ModelA {
  ModelA();
}

// --- APPROACH B (Literal Default Values in MappingRule) ---
enum ExampleEnum { value1, value2 }

class TargetB {
  final ExampleEnum enumValue;
  final String fallbackStr;

  TargetB({
    required this.enumValue,
    required this.fallbackStr,
  });
}

@ShouldGenerate(r'''
extension ModelBToTargetB on ModelB {
  TargetB toTargetB() {
    return TargetB(enumValue: ExampleEnum.value2, fallbackStr: 'default_str');
  }

  void updateTargetB(TargetB target) {}
}

extension ModelBToTargetBList on Iterable<ModelB> {
  List<TargetB> toTargetBList() {
    return map((e) => e.toTargetB()).toList();
  }
}
''')
@OmniMapper(
  target: TargetB,
  methodName: 'toTargetB',
  mappings: [
    MappingRule('enumValue', defaultValue: ExampleEnum.value2),
    MappingRule('fallbackStr', defaultValue: 'default_str'),
  ],
)
class ModelB {
  ModelB();
}
