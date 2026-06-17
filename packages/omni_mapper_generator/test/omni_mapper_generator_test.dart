import 'package:omni_mapper_generator/src/omni_mapper_generator.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test/src',
    'generator_test_inputs.dart',
  );

  initializeBuildLogTracking();

  testAnnotatedElements(
    reader,
    MapperGenerator(),
  );
}
