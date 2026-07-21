part of 'chats_bloc.dart';

enum ChatsStatus { loading, success, failure }

class ChatsState extends Equatable {
  const ChatsState._({
    required this.status,
    this.conversations = const [],
    this.failure,
  });

  const ChatsState.loading() : this._(status: ChatsStatus.loading);

  const ChatsState.success(List<Conversation> conversations)
      : this._(status: ChatsStatus.success, conversations: conversations);

  const ChatsState.failure(AppException failure)
      : this._(status: ChatsStatus.failure, failure: failure);

  final ChatsStatus status;
  final List<Conversation> conversations;
  final AppException? failure;

  bool get isEmpty =>
      status == ChatsStatus.success && conversations.isEmpty;

  @override
  List<Object?> get props => [status, conversations, failure];
}
