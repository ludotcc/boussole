typedef UndoCallback = Future<void> Function();

class UndoAction {
  const UndoAction({
    required this.description,
    required this.undo,
    this.timestamp,
  });

  final String description;

  final UndoCallback undo;

  final DateTime? timestamp;
}
