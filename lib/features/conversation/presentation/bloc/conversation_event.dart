part of 'conversation_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page and marks the thread read.
final class ConversationOpened extends ConversationEvent {
  const ConversationOpened();
}

/// Loads the next, older page when the user scrolls back far enough.
final class ConversationOlderPageRequested extends ConversationEvent {
  const ConversationOlderPageRequested();
}

final class ConversationMessageSent extends ConversationEvent {
  const ConversationMessageSent(this.content);

  final String content;

  @override
  List<Object?> get props => [content];
}

/// Re-sends a message whose first attempt failed.
final class ConversationMessageRetried extends ConversationEvent {
  const ConversationMessageRetried(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}
