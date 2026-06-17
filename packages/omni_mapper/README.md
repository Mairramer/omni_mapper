# OmniMapper

[![pub package](https://img.shields.io/pub/v/omni_mapper.svg)](https://pub.dev/packages/omni_mapper)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful, highly customizable code-generation library for Dart and Flutter that automatically generates **object-to-object mapping** code.

OmniMapper eliminates the boilerplate of manually writing conversion methods between your application layers (e.g., `Model` → `Entity`, `DTO` → `ViewModel`), keeping your codebase clean and reducing bugs.

> **Think of it as the AutoMapper/MapStruct for the Dart ecosystem.**

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  omni_mapper: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  omni_mapper_generator: ^0.1.0
```

Then run:
```bash
dart pub get
```

## Quick Start

### 1. Annotate your class

```dart
import 'package:omni_mapper/omni_mapper.dart';

part 'user_model.g.dart';

class UserEntity {
  final int id;
  final String name;
  UserEntity({required this.id, required this.name});
}

@OmniMapper(target: UserEntity)
class UserModel {
  final int id;
  final String name;
  UserModel({required this.id, required this.name});
}
```

### 2. Run the generator

```bash
dart run build_runner build -d
```

### 3. Use the generated code

```dart
final model = UserModel(id: 1, name: 'John');
final entity = model.toEntity(); // Automatically mapped!
```

## Mapping Approaches

OmniMapper supports three mapping strategies to fit your architecture:

### Approach A: Abstract Class (Centralized Mapper)

```dart
@OmniMapper()
abstract class UserMapper {
  UserEntity toEntity(UserModel model);
}
// Generates: class UserMapperImpl extends UserMapper { ... }
```

### Approach B: Extension TO Target

```dart
@OmniMapper(target: UserEntity)
class UserModel { ... }
// Generates: extension on UserModel { UserEntity toEntity() { ... } }
```

### Approach C: Extension FROM Source

```dart
@OmniMapper(from: UserEntity, methodName: 'toModel')
class UserModel { ... }
// Generates: extension on UserEntity { UserModel toModel() { ... } }
```

### Multiple Mappings

Map a single class to multiple targets using `@OmniMappers`:

```dart
@OmniMappers([
  OmniMapper(target: UserEntity),
  OmniMapper(from: UserEntity, methodName: 'toModel'),
])
class UserModel { ... }
```

## Advanced Features

### Custom Field Mapping

When source and target have different property names:

```dart
@OmniMapper(
  target: UserEntity,
  fieldMaps: {'userId': 'id'}, // source.userId → target.id
)
class UserModel {
  final int userId;
  // ...
}
```

### Default Values

Provide fallback values for target fields missing in the source:

```dart
@OmniMapper(
  target: UserEntity,
  defaultValues: {'status': '"active"', 'createdAt': 'DateTime.now()'},
)
```

### Custom Type Converters

Handle type mismatches with `OmniConverter`:

```dart
class DateTimeStringConverter extends OmniConverter<String, DateTime> {
  const DateTimeStringConverter();

  @override
  DateTime convert(String source) => DateTime.parse(source);
}

@OmniMapper(
  target: UserEntity,
  converters: [DateTimeStringConverter],
)
class UserModel {
  final String createdAt; // String → DateTime automatically
}
```

### List Generation

Automatically generates an extension on `Iterable<Source>` for batch mapping:

```dart
final models = [model1, model2, model3];
final entities = models.toEntityList(); // Returns List<UserEntity>
```

> Enabled by default. Disable with `generateListMapper: false`.

### In-Place Updates

Generates a method to update an existing target instance without creating a new one:

```dart
final existingEntity = UserEntity(id: 1, name: 'Old');
formModel.updateUserEntity(existingEntity);
// existingEntity.name is now updated — same object in memory!
```

> Enabled by default. Disable with `generateUpdateMethod: false`.
> Works with mutable fields only (non-`final`).

### Ignoring Fields

Skip specific fields during mapping:

```dart
@OmniMapper(target: UserEntity, ignoreFields: ['passwordHash'])
```

## Recommended `build.yaml`

To suppress lint warnings on generated files, add this to your project's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      source_gen|combining_builder:
        options:
          ignore_for_file:
            - type=lint
            - coverage:ignore-file
```

## Running the Generator

```bash
# One-time build
dart run build_runner build -d

# Watch mode (rebuilds on file changes)
dart run build_runner watch -d
```

## Contributing

Contributions are welcome! Please file issues and pull requests on the [GitHub repository](https://github.com/Mairramer/omni_mapper).

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
