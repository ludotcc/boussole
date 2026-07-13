import 'package:flutter/foundation.dart';

import 'undo_action.dart';

class UndoManager extends ChangeNotifier {
  UndoAction? _lastAction;

  bool get canUndo => _lastAction != null;

  String? get lastDescription => _lastAction?.description;

  void register(UndoAction action) {
    _lastAction = action;
    notifyListeners();
  }

  Future<void> undo() async {
    final action = _lastAction;

    if (action == null) {
      return;
    }

    _lastAction = null;
    notifyListeners();

    await action.undo();
  }

  void clear() {
    _lastAction = null;
    notifyListeners();
  }
}
