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

/// A message pushed by the server for this conversation.
final class ConversationMessageReceived extends ConversationEvent {
  const ConversationMessageReceived(this.message);

  final Message message;

  @override
  List<Object?> get props => [message];
}

/// The other participant read the thread.
final class ConversationReadByOther extends ConversationEvent {
  const ConversationReadByOther();
}

/// The realtime connection came back; reload to catch up on anything
/// missed while it was down.
final class ConversationReconnected extends ConversationEvent {
  const ConversationReconnected();
}
