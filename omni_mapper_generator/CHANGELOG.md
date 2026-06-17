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
