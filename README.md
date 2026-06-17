# OmniMapper

A powerful, highly customizable, code-generation mapping library for Dart and Flutter. 

OmniMapper automatically generates boilerplate code to map data between your application layers (e.g., from `Model` to `Entity`, from `DTO` to `Model`), keeping your codebase clean and reducing manual bugs.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  omni_mapper: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
  omni_mapper_generator: ^1.0.0
```

## Basic Usage

OmniMapper allows you to create extension methods to convert objects. Just annotate your class with `@OmniMapper`.

### Mapping TO a Target

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

Run `dart run build_runner build -d`, and OmniMapper will generate an extension:
```dart
final model = UserModel(id: 1, name: 'John');
final entity = model.toEntity(); // Automatically mapped!
```

### Multiple Mappings

You can map to multiple targets by using `@OmniMappers`:
```dart
@OmniMappers([
  OmniMapper(target: UserEntity),
  OmniMapper(target: AnotherEntity, methodName: 'toAnother'),
])
class UserModel { ... }
```

## Advanced Features

OmniMapper comes packed with advanced tools to handle real-world mapping scenarios.

### 1. Custom Field Mapping (`fieldMaps`)
When your source and target classes use different property names, use `fieldMaps`.

```dart
@OmniMapper(
  target: UserEntity,
  fieldMaps: {'userId': 'id'}, // maps source.userId -> target.id
)
class UserModel {
  final int userId;
  // ...
}
```

### 2. Default Values (`defaultValues`)
If the target class requires a field that doesn't exist on the source, you can specify a fallback raw Dart string value.

```dart
@OmniMapper(
  target: UserEntity,
  defaultValues: {'status': '"active"', 'createdAt': 'DateTime.now()'}, 
)
```

### 3. Custom Type Converters (`converters`)
To handle type mismatches (e.g., parsing a `String` into a `DateTime`), define an `OmniConverter` and pass it to the annotation.

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
  final String createdAt;
}
```

### 4. Iterable Generation (`generateListMapper`)
By default, the generator creates an extension for `Iterable<Model>` objects, so you can easily map arrays.

```dart
final modelList = [model1, model2];
final entityList = modelList.toEntityList(); // Returns List<UserEntity>
```

### 5. In-Place Updates (`generateUpdateMethod`)
By default, the generator creates a method `updateEntity(Target target)` that mutates an existing instance of the target class with the values from the source class. (Note: This skips `final` fields since they cannot be mutated).

```dart
final existingEntity = UserEntity();
model.updateUserEntity(existingEntity);
```

### 6. Ignoring Fields (`ignoreFields`)
To purposefully skip mapping specific fields:
```dart
@OmniMapper(target: UserEntity, ignoreFields: ['passwordHash'])
```

## Running the Generator

Once you have set up your annotations, run the build runner:

```bash
dart run build_runner build -d
```
