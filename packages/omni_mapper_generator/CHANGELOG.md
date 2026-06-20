## 0.4.0

- **Feat**: Code generation logic for the new `uses` property (dependency injection).
- **Feat**: Code generation for polymorphic subclass mapping (`@SubclassMapping`).
- **Feat**: Support for evaluating literal default values in `defaultValues`.
- **Fix**: Correctly invoke named constructors (e.g., `super.named()`) when using `uses` instead of the unnamed constructor.
- **Fix**: Fixed target field shadowing issue when mapping nested fields (`target.name`).
- **Fix**: Replaced silent null returns with `InvalidGenerationSourceError` during unparseable annotation elements.
- **Fix**: Added validation to throw an error when a fallback dependency requires constructor arguments without explicit injection.

## 0.3.0

- **Feat**: Code generation support for multiple sources in mapper methods.
- **Feat**: Code generation for automatic Enum mapping.
- **Feat**: Implemented deep auto-flattening code generation for nested fields (`address.street`).
- **Feat**: Code generation for automatic reverse mapping (`generateReverse`).

## 0.2.0

- **Feat**: Implemented `strictMode` generation logic and validation.
- **Feat**: Implemented `ignoreIfNull` generation for update methods.
- **Feat**: Added support for custom mapping hooks (`hook`) logic generation.
- **Fix**: Prevent false positives in strict mode for fields with initializers or default values.
- **Fix**: Removed `const` requirements for custom mapping hooks in generated code.
- **Fix**: Removed unnecessary null-check warnings from Dart analyzer when using `ignoreIfNull`.

## 0.1.0

- Initial release.
- Code generation support for `@OmniMapper` and `@OmniMappers` annotations.
- Supported generation strategies:
  - **Abstract Class** — generates a concrete implementation class.
  - **Extension TO** — generates an extension on the annotated class mapping to a target.
  - **Extension FROM** — generates an extension on a source class mapping to the annotated class.
- Advanced features:
  - Custom field mapping via `fieldMaps`.
  - Default values via `defaultValues`.
  - Custom type converters via `converters` and `OmniConverter`.
  - List mapper generation via `generateListMapper`.
  - In-place update method generation via `generateUpdateMethod`.
  - Field ignoring via `ignoreFields`.
