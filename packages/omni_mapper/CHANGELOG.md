## 0.5.0

* Introduces `@OmniField` annotation for fine-grained field-level configuration directly on class properties.
* Adds support for `name`, `ignore`, `custom`, and `defaultValue` inside `@OmniField`.
* Unifies default value and custom mapping type validations.

## 0.4.0

* Introduces the `uses` property to `@OmniMapper` for robust dependency injection and nested mapper integration.
* Adds support for polymorphic subclass mapping via `@SubclassMapping`.
* Implements `MappingRule` custom field expressions.
* Supports evaluating literal default values during code generation.

## 0.3.0

* Adds support for mapping from multiple source objects into a single target.
* Adds automatic enum mapping (`approach_i_enum_mapping.dart`).
* Implements deep auto-flattening for nested mapping.
* Adds automatic reverse mapping via the `generateReverse` option.

## 0.2.0

* Adds `strictMode` mapping option to enforce complete mappings.
* Adds `ignoreIfNull` mapping option for PATCH-like object updates.
* Introduces custom mapping hooks via the `OmniHook` abstract class.

## 0.1.0

* Initial release.
* Adds `@OmniMapper` annotation with support for `target`, `from`, `methodName`, `fieldMaps`, `defaultValues`, `converters`, `ignoreFields`, `generateListMapper`, and `generateUpdateMethod`.
* Adds `@OmniMappers` annotation for defining multiple mappings on a single class.
* Adds `OmniConverter<S, T>` abstract class for custom type conversions.
