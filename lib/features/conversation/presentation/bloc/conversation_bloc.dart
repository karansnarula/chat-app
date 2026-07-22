import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/usecases/get_current_user_id_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/get_messages_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/mark_as_read_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/send_message_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

@injectable
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc(
    @factoryParam this.conversationId,
    this._getMessages,
    this._sendMessage,
    this._markAsRead,
    this._getCurrentUserId,
  ) : super(const ConversationState()) {
    on<ConversationOpened>(_onOpened);
    on<ConversationOlderPageRequested>(_onOlderPageRequested);
    on<ConversationMessageSent>(_onMessageSent);
    on<ConversationMessageRetried>(_onMessageRetried);
  }

  final String conversationId;
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final MarkAsReadUseCase _markAsRead;
  final GetCurrentUserIdUseCase _getCurrentUserId;

  /// Distinguishes an optimistic message from a server-assigned id.
  static const localIdPrefix = 'local-';

  Future<void> _onOpened(
    ConversationOpened event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.loading));

    final userId = await _getCurrentUserId();
    final result = await _getMessages(conversationId: conversationId);

    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            status: ConversationStatus.success,
            messages: value.messages,
            currentUserId: userId,
            nextCursor: value.nextCursor,
            clearCursor: value.nextCursor == null,
            clearFailure: true,
          ),
        );
        // Best effort: the badge clearing is not worth surfacing an error.
        await _markAsRead(conversationId);
      case Failure(:final exception):
        emit(
          state.copyWith(
            status: ConversationStatus.failure,
            currentUserId: userId,
            failure: exception,
          ),
        );
    }
  }

  Future<void> _onOlderPageRequested(
    ConversationOlderPageRequested event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.isLoadingOlder || !state.hasMore) return;

    emit(state.copyWith(isLoadingOlder: true));

    final result = await _getMessages(
      conversationId: conversationId,
      cursor: state.nextCursor,
    );

    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            messages: [...state.messages, ...value.messages],
            nextCursor: value.nextCursor,
            clearCursor: value.nextCursor == null,
            isLoadingOlder: false,
          ),
        );
      case Failure():
        // Keep what is already loaded; the user can scroll to retry.
        emit(state.copyWith(isLoadingOlder: false));
    }
  }

  /// Shows the message immediately, then swaps in the server copy so the
  /// thread never feels like it is waiting on the network.
  Future<void> _onMessageSent(
    ConversationMessageSent event,
    Emitter<ConversationState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty) return;

    final optimistic = Message(
      id: '$localIdPrefix${DateTime.now().microsecondsSinceEpoch}',
      content: content,
      senderId: state.currentUserId ?? '',
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    emit(state.copyWith(messages: [optimistic, ...state.messages]));

    await _deliver(optimistic, emit);
  }

  Future<void> _onMessageRetried(
    ConversationMessageRetried event,
    Emitter<ConversationState> emit,
  ) async {
    final failed = state.messages
        .where((message) => message.id == event.localId)
        .firstOrNull;
    if (failed == null) return;

    emit(
      state.copyWith(
        messages: _replace(
          event.localId,
          failed.copyWith(status: MessageStatus.sending),
        ),
      ),
    );

    await _deliver(failed, emit);
  }

  Future<void> _deliver(
    Message optimistic,
    Emitter<ConversationState> emit,
  ) async {
    final result = await _sendMessage(
      conversationId: conversationId,
      content: optimistic.content,
    );

    switch (result) {
      case Success(:final value):
        emit(state.copyWith(messages: _replace(optimistic.id, value)));
      case Failure():
        emit(
          state.copyWith(
            messages: _replace(
              optimistic.id,
              optimistic.copyWith(status: MessageStatus.failed),
            ),
          ),
        );
    }
  }

  List<Message> _replace(String id, Message replacement) => [
        for (final message in state.messages)
          if (message.id == id) replacement else message,
      ];
}
