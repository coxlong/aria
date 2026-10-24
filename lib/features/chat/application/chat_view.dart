import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../domain/chat/chat_turn.dart';

part 'chat_view.freezed.dart';

/// Everything the chat surface renders for one session.
@freezed
abstract class ChatView with _$ChatView {
  const factory ChatView({
    required String sessionId,
    @Default(<ChatTurn>[]) List<ChatTurn> turns,
    @Default(false) bool running,
    @Default(false) bool stopping,
    AppError? error,
  }) = _ChatView;

  const ChatView._();

  ChatTurn? get lastTurn => turns.isEmpty ? null : turns.last;

  bool get hasTurns => turns.isNotEmpty;
}
