---
name: pub-changelog-guidelines
description: |-
  Guidelines for writing CHANGELOG.md files using the pub.dev standard,
  based on the official camera package changelog pattern.
---

# Pub Changelog Guidelines

## 1. When to use this skill
Use this skill when:
- Creating or updating `CHANGELOG.md` files for dart/flutter packages.
- Generating release notes.

## 2. Best Practices

### Formatting
Always use the following format for changelog entries, modeled after the official Flutter `camera` package:

1. **Version Header:** Start with `## [VERSION]` (e.g., `## 0.5.0`). If adding a build number, use `## [VERSION]+[BUILD]` (e.g., `## 0.12.0+1`).
2. **Bullet Points:** Use `* ` (an asterisk followed by a space) for list items instead of `- ` or prefixing with `**Feat**:`.
3. **Action Verbs:** Start each bullet point with a present-tense third-person verb (usually ending in 's'), such as:
   - `Adds`
   - `Fixes`
   - `Updates`
   - `Removes`
   - `Introduces`
   - `Makes`
4. **Punctuation:** End each bullet point sentence with a period (`.`).

**Avoid:**
```markdown
## 0.5.0

- **Feat**: Introduced a new feature.
- **Fix**: Fixed a bug in the core library.
```

**Prefer:**
```markdown
## 0.5.0

* Adds a new feature.
* Fixes a bug in the core library.
```
