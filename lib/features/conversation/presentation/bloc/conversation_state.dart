part of 'conversation_bloc.dart';

enum ConversationStatus { loading, success, failure }

class ConversationState extends Equatable {
  const ConversationState({
    this.status = ConversationStatus.loading,
    this.messages = const [],
    this.currentUserId,
    this.nextCursor,
    this.isLoadingOlder = false,
    this.failure,
  });

  final ConversationStatus status;

  /// Newest first, matching the backend order and the reversed list view.
  final List<Message> messages;
  final String? currentUserId;
  final String? nextCursor;
  final bool isLoadingOlder;
  final AppException? failure;

  bool get hasMore => nextCursor != null;

  bool get isEmpty =>
      status == ConversationStatus.success && messages.isEmpty;

  bool isMine(Message message) => message.senderId == currentUserId;

  ConversationState copyWith({
    ConversationStatus? status,
    List<Message>? messages,
    String? currentUserId,
    String? nextCursor,
    bool? isLoadingOlder,
    AppException? failure,
    bool clearCursor = false,
    bool clearFailure = false,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        currentUserId,
        nextCursor,
        isLoadingOlder,
        failure,
      ];
}
