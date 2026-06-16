# Omni Mapper

Annotations package for the `omni_mapper_generator`.

This package provides the `@OmniMapper` annotation, which you can use to annotate your Dart classes to automatically generate mappers.

## Installation

Add both the `omni_mapper` and `omni_mapper_generator` packages to your `pubspec.yaml`:

```yaml
dependencies:
  omni_mapper: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  omni_mapper_generator: ^0.1.0
```

## Usage

Annotate your class with `@OmniMapper`:

```dart
import 'package:omni_mapper/omni_mapper.dart';

@OmniMapper(target: UserEntity)
class UserModel {
  final int id;
  final String name;
  
  UserModel({required this.id, required this.name});
}
```

Run the build runner:
```sh
dart run build_runner build
```
