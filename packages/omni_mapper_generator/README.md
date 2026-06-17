# OmniMapper Generator

[![pub package](https://img.shields.io/pub/v/omni_mapper_generator.svg)](https://pub.dev/packages/omni_mapper_generator)
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Code generator for the [`omni_mapper`](https://pub.dev/packages/omni_mapper) package.

This package automatically generates type-safe object-to-object mapping code, eliminating boilerplate for converting between DTOs, Models, Entities, and ViewModels.

## Installation

Add this package as a `dev_dependency` alongside `build_runner`, and add `omni_mapper` to your normal dependencies:

```yaml
dependencies:
  omni_mapper: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  omni_mapper_generator: ^0.1.0
```

## Features

- **Extension-based mapping** — generates clean extension methods on your classes
- **Bidirectional mapping** — use `target` (Model → Entity) or `from` (Entity → Model)
- **Custom field mapping** — rename fields between source and target
- **Type converters** — handle type mismatches with `OmniConverter`
- **Default values** — provide fallbacks for missing fields
- **List generation** — batch-map iterables automatically
- **In-place updates** — mutate existing objects without creating new ones
- **Multi-mapper** — map a single class to multiple targets with `@OmniMappers`

## Usage

For detailed usage instructions and examples, please refer to the [`omni_mapper` package documentation](https://pub.dev/packages/omni_mapper).

## Running the Generator

```bash
# One-time build
dart run build_runner build -d

# Watch mode
dart run build_runner watch -d
```

## License

This project is licensed under the BSD 3-Clause License — see the [LICENSE](LICENSE) file for details.
