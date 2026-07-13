import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'undo_manager.dart';

final undoProvider = ChangeNotifierProvider<UndoManager>((ref) {
  return UndoManager();
});
