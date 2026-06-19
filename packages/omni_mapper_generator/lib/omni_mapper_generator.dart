/// Generates code for the `omni_mapper` package.
library;

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'src/omni_mapper_generator.dart';

/// Builds generators for `omni_mapper` annotations.
///
/// Configures a [SharedPartBuilder] that applies [MapperGenerator] and
/// [MultiMapperGenerator] to generate mapping code.
Builder mapperBuilder(BuilderOptions options) => SharedPartBuilder(
  [MapperGenerator(), MultiMapperGenerator()],
  formatOutput: (code, languageVersion) => DartFormatter(
    pageWidth: 80,
    trailingCommas: TrailingCommas.preserve,
    languageVersion: languageVersion,
  ).format(code),
  'mapper',
);
