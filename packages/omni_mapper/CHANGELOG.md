## 0.4.0

- **Feat**: Introduced the `uses` property to `@OmniMapper` for robust dependency injection and nested mapper integration.
- **Feat**: Added support for polymorphic subclass mapping via `@SubclassMapping`.
- **Feat**: Implemented `MappingRule` custom field expressions.
- **Feat**: Supported evaluating literal default values during code generation.

## 0.3.0

- **Feat**: Support for mapping from multiple source objects into a single target.
- **Feat**: Added automatic enum mapping (`approach_i_enum_mapping.dart`).
- **Feat**: Implemented deep auto-flattening for nested mapping.
- **Feat**: Added automatic reverse mapping via the `generateReverse` option.

## 0.2.0

- **Feat**: Added `strictMode` mapping option to enforce complete mappings.
- **Feat**: Added `ignoreIfNull` mapping option for PATCH-like object updates.
- **Feat**: Introduced custom mapping hooks via the `OmniHook` abstract class.

## 0.1.0

- Initial release.
- Added `@OmniMapper` annotation with support for:
  - `target` — map the annotated class TO a target type.
  - `from` — map FROM a source type TO the annotated class.
  - `methodName` — customize the generated method name.
  - `fieldMaps` — custom field name mapping between source and target.
  - `defaultValues` — fallback values for missing fields.
  - `converters` — custom type converters via `OmniConverter<S, T>`.
  - `ignoreFields` — skip specific fields during mapping.
  - `generateListMapper` — auto-generate batch mapping for iterables.
  - `generateUpdateMethod` — auto-generate in-place update methods.
- Added `@OmniMappers` annotation for defining multiple mappings on a single class.
- Added `OmniConverter<S, T>` abstract class for custom type conversions.
