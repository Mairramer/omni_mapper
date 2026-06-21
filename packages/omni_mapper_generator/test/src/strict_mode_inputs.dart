import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

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
    return TargetF(id: id);
  }
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
  'To fix this, map them from the source, provide a defaultValue, or ignore them using @OmniField or mappings.',
)
@OmniMapper(target: TargetG, strictMode: true, methodName: 'toTargetG')
class ModelG {
  final int id;
  ModelG({required this.id});
}
