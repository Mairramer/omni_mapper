## 0.5.0

* Adds code generation support for `@OmniField` annotation (`name`, `ignore`, `custom`, `defaultValue`).
* Fixes strict type-checking for default values across both `MappingRule` and `@OmniField` at compile-time.
* Standardizes `@OmniField` configuration extraction between extension mappers and abstract class generators.

## 0.4.0

* Adds code generation logic for the new `uses` property (dependency injection).
* Adds code generation for polymorphic subclass mapping (`@SubclassMapping`).
* Adds support for evaluating literal default values in `defaultValues`.
* Fixes target field shadowing issue when mapping nested fields (`target.name`).
* Fixes silent null returns with `InvalidGenerationSourceError` during unparseable annotation elements.
* Fixes a bug to correctly invoke named constructors (e.g., `super.named()`) when using `uses` instead of the unnamed constructor.
* Adds validation to throw an error when a fallback dependency requires constructor arguments without explicit injection.

## 0.3.0

* Adds code generation support for multiple sources in mapper methods.
* Adds code generation for automatic Enum mapping.
* Implements deep auto-flattening code generation for nested fields (`address.street`).
* Adds code generation for automatic reverse mapping (`generateReverse`).

## 0.2.0

* Implements `strictMode` generation logic and validation.
* Implements `ignoreIfNull` generation for update methods.
* Adds support for custom mapping hooks (`hook`) logic generation.
* Fixes strict mode false positives for fields with initializers or default values.
* Removes `const` requirements for custom mapping hooks in generated code.
* Removes unnecessary null-check warnings from Dart analyzer when using `ignoreIfNull`.

## 0.1.0

* Initial release.
* Adds code generation support for `@OmniMapper` and `@OmniMappers` annotations.
* Supports generation strategies: Abstract Class, Extension TO, and Extension FROM.
* Supports advanced features: custom field mapping, default values, custom type converters, list mapper generation, in-place update method generation, and field ignoring.
