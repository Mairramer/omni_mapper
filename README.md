# OmniMapper

[![pub package](https://img.shields.io/pub/v/omni_mapper.svg)](https://pub.dev/packages/omni_mapper)
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A powerful, highly customizable code-generation library for Dart and Flutter that automatically generates **object-to-object mapping** code.

OmniMapper eliminates the boilerplate of manually writing conversion methods between your application layers (e.g., `Model` → `Entity`, `DTO` → `ViewModel`), keeping your codebase clean and reducing bugs.

> **Think of it as the AutoMapper/MapStruct for the Dart ecosystem.**

## Packages

This is a monorepo containing the following packages:

| Package | Description | pub.dev |
|---|---|---|
| [`omni_mapper`](./packages/omni_mapper) | Annotations (`@OmniMapper`, `@OmniMappers`) & `OmniConverter` interface | [![pub](https://img.shields.io/pub/v/omni_mapper.svg)](https://pub.dev/packages/omni_mapper) |
| [`omni_mapper_generator`](./packages/omni_mapper_generator) | Code generator (powered by `source_gen` + `build_runner`) | [![pub](https://img.shields.io/pub/v/omni_mapper_generator.svg)](https://pub.dev/packages/omni_mapper_generator) |

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  omni_mapper: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  omni_mapper_generator: ^0.1.0
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

## Features

- ✅ **Extension-based mapping** — generates clean extension methods
- ✅ **Bidirectional mapping** — `target` (Model → Entity) or `from` (Entity → Model)
- ✅ **Custom field mapping** — rename fields between source and target
- ✅ **Type converters** — handle type mismatches with `OmniConverter`
- ✅ **Default values** — provide fallbacks for missing fields
- ✅ **List generation** — batch-map iterables automatically
- ✅ **In-place updates** — mutate existing objects without creating new ones
- ✅ **Multi-mapper** — map a single class to multiple targets with `@OmniMappers`
- ✅ **Abstract class mapper** — centralized mapper pattern
- ✅ **Works alongside `json_serializable`** — zero conflicts

For detailed documentation and advanced usage, see the [`omni_mapper` package README](./packages/omni_mapper/README.md).

## Roadmap

To make OmniMapper the ultimate solution for the Dart/Flutter ecosystem (similar to MapStruct/AutoMapper), we are focusing on the following features:

- [x] **Multiple Sources Mapping:** Combine multiple source objects into a single target object.
- [x] **Full Freezed/BuiltValue Compatibility:** Flawless support for Factory Constructors.
- [ ] **Context Passing (`@Context`):** Pass dependencies/state down the mapping tree.
- [x] **Polymorphic Mapping:** Handle subclasses and inheritance dynamically (`@SubclassMapping`).
- [x] **Utilizing other Mappers:** Reference existing injectable mappers (`uses: [OtherMapper]`).
- [ ] **Collection Update Strategies:** Option to `clear()` and `addAll()` instead of replacing the list reference.
- [x] **Custom Field Expressions:** Pure Dart code passed as a string for extreme flexibility.
- [ ] **`@MapFrom` Annotation:** A dedicated annotation for renaming fields to simplify the `fieldMaps` approach.

## Contributing

Contributions are welcome! Please file issues and pull requests on the [GitHub repository](https://github.com/Mairramer/omni_mapper).

## License

This project is licensed under the BSD 3-Clause License — see the [LICENSE](LICENSE) file for details.
