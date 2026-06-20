import 'package:omni_mapper_generator/src/omni_mapper_generator.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  initializeBuildLogTracking();

  final testFiles = [
    'abstract_class_inputs.dart',
    'extension_mapping_inputs.dart',
    'advanced_features_inputs.dart',
    'strict_mode_inputs.dart',
    'error_inputs.dart',
    'uses_inputs.dart',
    'default_values_inputs.dart',
  ];

  for (final file in testFiles) {
    final reader = await initializeLibraryReaderForDirectory('test/src', file);
    testAnnotatedElements(reader, MapperGenerator());
  }
}
