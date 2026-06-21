---
name: flutter-style-guide
description: |-
  Core style guidelines for Flutter repo and related packages.
  Covers API design, documentation, and programming patterns.
---

# Flutter Style Guide

## 1. When to use this skill
Use this skill when:
- Designing new APIs or refactoring existing ones.
- Writing documentation (dartdocs).
- Making architectural decisions or reviewing code for Flutter projects.

## 2. API Design & Architecture
- **Layers:** Design using layers where each layer addresses a narrow problem. Convenience APIs belong at the layer *above* the one they simplify.
- **Top-Down API Design:** Always design the top-level API first (the one developers will interact with), then build lower levels to fit.
- **Avoid Interleaving Concepts:** Each API should be self-contained. For example, widgets shouldn't act differently based on the type (`is`) of their `child`.
- **Avoid Secret (Global) State:** Functions/methods should operate only on their arguments and instance variables. Avoid side effects that rely on or alter hidden global state.
- **No Synchronous Slow Work:** Expensive operations should be asynchronous (`Future` or `Stream`).
- **Getters vs Methods:** Getters must be fast (O(1) lookups or cached values) and idempotent. If an operation does heavy work or returns a new `Future` that starts work, it must be a method.

## 3. Programming Practices
- **Lazy Programming:** Write exactly what you need and no more. Avoid speculative "for completeness" features. When fixing a bug, do it right rather than applying a workaround (embrace the yak shave!).
- **Write Test, Find Bug:** When fixing a bug, first write a failing test, then fix the bug to make it pass. Ensure high test coverage.
- **Single Source of Truth:** Do not duplicate live state.
- **Forbidden Constructs:** 
  - Never use timeouts or timers for synchronization or tests.
  - Avoid `is` for logic branching where polymorphism or generics should be used.
  - Avoid `print` (use proper logging instead).
  - Avoid `part of` (use standard imports).
  - Avoid `extension` methods when regular methods or wrapper classes are cleaner in framework code.

## 4. Documentation
- **Answer Questions Straight Away:** If you had to look up how something works, add that answer to the dartdoc of the class/method where you looked.
- **Leave Breadcrumbs:** Tell the user *how* to get an instance of the class (e.g., "created by `FooBuilder`") or *where* to use it (e.g., "pass this to `Bar.add()`").
- **Avoid Useless Prose:** Don't write documentation that just repeats the property name. Explain edge cases, nullability, defaults, and interactions.
- **Canonical Terminology:** 
  - *Method*: member of a class.
  - *Function*: callable closure not bound to a class.
  - *Parameter*: variable in a signature.
  - *Argument*: value passed to a call.

## 5. Errors and Logs
- **Useful Error Messages:** Every error is an opportunity to help the user. Explain *why* it happened and *how* to fix it.
- **Actionable Logs:** Only log actual errors or warnings that the developer can do something about. Never log "informational" messages by default.
