library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/omni_mapper_generator.dart';

Builder mapperBuilder(BuilderOptions options) => SharedPartBuilder(
  [MapperGenerator(), MultiMapperGenerator()],
  'mapper',
);
