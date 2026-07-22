import 'dart:async';

import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/domain/usecases/get_conversations_use_case.dart';
import 'package:chat_app/features/chats/domain/usecases/watch_conversations_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

part 'chats_event.dart';
part 'chats_state.dart';

@injectable
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc(
    this._getConversations,
    WatchConversationsUseCase watchConversations,
  ) : super(const ChatsState.loading()) {
    on<ChatsRequested>(_onRequested);
    on<ChatsRefreshed>(
      _onRefreshed,
      // Bursts of socket events collapse into a single refetch.
      transformer: (events, mapper) =>
          events.debounce(AppDurations.fast).switchMap(mapper),
    );

    _invalidationSubscription =
        watchConversations().listen((_) => add(const ChatsRefreshed()));
  }

  final GetConversationsUseCase _getConversations;
  late final StreamSubscription<void> _invalidationSubscription;

  Future<void> _onRequested(
    ChatsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    emit(const ChatsState.loading());
    await _load(emit);
  }

  /// Refresh leaves the existing list on screen; only a failure replaces it.
  Future<void> _onRefreshed(
    ChatsRefreshed event,
    Emitter<ChatsState> emit,
  ) =>
      _load(emit);

  Future<void> _load(Emitter<ChatsState> emit) async {
    final result = await _getConversations();
    switch (result) {
      case Success(:final value):
        emit(ChatsState.success(value));
      case Failure(:final exception):
        emit(ChatsState.failure(exception));
    }
  }

  @override
  Future<void> close() async {
    await _invalidationSubscription.cancel();
    return super.close();
  }
}
