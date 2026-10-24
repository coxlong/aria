import 'package:acp/acp.dart';
import 'package:flutter/foundation.dart';

import 'conversation_reducer.dart';

/// UI-facing wrapper around [ConversationReducer].
final class ConversationController extends ChangeNotifier {
  final ConversationReducer _reducer = ConversationReducer();

  List<ChatMessage> get messages => _reducer.messages;

  void reset() {
    _reducer.reset();
    notifyListeners();
  }

  void beginReplay() => _reducer.beginReplay();

  void endReplay() {
    _reducer.endReplay();
    notifyListeners();
  }

  void beginTurn(String text) {
    _reducer.onUserMessage(text);
    notifyListeners();
  }

  void apply(SessionUpdate update) {
    _reducer.apply(update);
    notifyListeners();
  }

  void endTurn(String stopReason) {
    _reducer.endTurn(stopReason: stopReason);
    notifyListeners();
  }
}
