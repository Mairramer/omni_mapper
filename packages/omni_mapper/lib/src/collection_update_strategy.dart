/// Defines the strategy used when updating collection fields in an existing target.
enum CollectionUpdateStrategy {
  /// Replaces the target collection with the source collection reference.
  replace,

  /// Clears the target collection and adds all elements from the source collection.
  clearAndAddAll,

  /// Appends elements to the existing collection without clearing it first.
  /// For Maps, this merges the keys (updating existing and adding new ones).
  append,
}
