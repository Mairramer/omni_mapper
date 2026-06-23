# OmniMapper

[![pub package](https://img.shields.io/pub/v/omni_mapper.svg)](https://pub.dev/packages/omni_mapper)
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

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

When source and target have different property names, you have two options depending on your control over the classes:

#### Option 1: `@OmniField` (Recommended when you own the class)

Place `@OmniField` directly on the property. This is the most ergonomic approach because the mapping rule stays right next to the variable declaration.

```dart
@OmniMapper(target: UserEntity)
class UserModel {
  @OmniField(name: 'id') // Maps 'userId' to 'id'
  final int userId;
  // ...
}
```

#### Option 2: `mappings` with `MappingRule` (Recommended for external classes)

If you cannot modify the class (e.g., it belongs to a third-party package or is generated code), or if you need advanced custom expressions, use `MappingRule` inside `@OmniMapper`.

```dart
@OmniMapper(
  target: UserEntity,
  mappings: [
    MappingRule('id', source: 'userId'), // source.userId → target.id
  ],
)
class UserModel {
  final int userId;
  // ...
}
```

### Default Values

Provide fallback values for target fields missing in the source:

#### Option 1: `@OmniField`
```dart
class UserModel {
  @OmniField(defaultValue: '"active"')
  final String status;
}
```

#### Option 2: `mappings`
```dart
@OmniMapper(
  target: UserEntity,
  mappings: [
    MappingRule('status', defaultValue: '"active"'),
    MappingRule('createdAt', defaultValue: 'DateTime.now()'),
  ],
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

> Disabled by default. Enable with `generateUpdateMethod: true`.
> Works with mutable fields only (non-`final`), unless using a `CollectionUpdateStrategy` that mutates the collection in-place.

#### Collection Update Strategies

When `generateUpdateMethod: true`, you can configure how collections (`List`, `Set`, `Map`) are updated using `collectionUpdateStrategy` globally or per field:

- **`replace`** (Default): Assigns the new collection reference to the target field (`target.tags = tags;`).
- **`clearAndAddAll`**: Clears the existing collection and adds all items from the source (`target.tags.clear(); target.tags.addAll(tags);`). Works perfectly with `final` collections!
- **`append`**: Appends elements to the existing collection without clearing it first. For Maps, this acts as a merge, updating existing keys and adding new ones.

**Example (Global):**
```dart
@OmniMapper(
  target: UserEntity,
  generateUpdateMethod: true,
  collectionUpdateStrategy: CollectionUpdateStrategy.clearAndAddAll,
)
```

**Example (Per-Field overrides):**
```dart
class UserModel {
  @OmniField(collectionUpdateStrategy: CollectionUpdateStrategy.append)
  final List<String> tags;
}
```

### Ignoring Fields

Skip specific fields during mapping:

#### Option 1: `@OmniField`
```dart
class UserModel {
  @OmniField(ignore: true)
  final String passwordHash;
}
```

#### Option 2: `mappings`
```dart
@OmniMapper(
  target: UserEntity,
  mappings: [
    MappingRule('passwordHash', ignore: true),
  ],
)
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

This project is licensed under the BSD 3-Clause License — see the [LICENSE](LICENSE) file for details.
