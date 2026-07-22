import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';
import 'package:chat_app/features/friend_requests/domain/usecases/get_pending_requests_use_case.dart';
import 'package:chat_app/features/friend_requests/domain/usecases/respond_to_request_use_case.dart';
import 'package:chat_app/features/friend_requests/domain/usecases/send_friend_request_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'friend_requests_event.dart';
part 'friend_requests_state.dart';

/// App-scoped so the chats app bar and the requests screen share one
/// source of truth for the pending count.
@lazySingleton
class FriendRequestsBloc
    extends Bloc<FriendRequestsEvent, FriendRequestsState> {
  FriendRequestsBloc(
    this._getPendingRequests,
    this._respondToRequest,
    this._sendFriendRequest,
  ) : super(const FriendRequestsState()) {
    on<FriendRequestsRequested>(_onRequested);
    on<FriendRequestsRefreshed>(_onRefreshed);
    on<FriendRequestResponded>(_onResponded);
    on<FriendRequestSent>(_onSent);
    on<FriendRequestsOutcomeCleared>(_onOutcomeCleared);
  }

  final GetPendingRequestsUseCase _getPendingRequests;
  final RespondToRequestUseCase _respondToRequest;
  final SendFriendRequestUseCase _sendFriendRequest;

  Future<void> _onRequested(
    FriendRequestsRequested event,
    Emitter<FriendRequestsState> emit,
  ) async {
    emit(state.copyWith(status: FriendRequestsStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    FriendRequestsRefreshed event,
    Emitter<FriendRequestsState> emit,
  ) =>
      _load(emit);

  Future<void> _load(Emitter<FriendRequestsState> emit) async {
    final result = await _getPendingRequests();
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            status: FriendRequestsStatus.success,
            requests: value,
            clearFailure: true,
          ),
        );
      case Failure(:final exception):
        emit(
          state.copyWith(
            status: FriendRequestsStatus.failure,
            failure: exception,
          ),
        );
    }
  }

  /// Removes the request from the list on success; on failure the item
  /// stays put and the error surfaces as an outcome.
  Future<void> _onResponded(
    FriendRequestResponded event,
    Emitter<FriendRequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        awaitingResponseIds: {...state.awaitingResponseIds, event.requestId},
      ),
    );

    final result = await _respondToRequest(
      requestId: event.requestId,
      response: event.response,
    );

    final stillAwaiting = {...state.awaitingResponseIds}
      ..remove(event.requestId);

    switch (result) {
      case Success():
        emit(
          state.copyWith(
            requests: state.requests
                .where((request) => request.id != event.requestId)
                .toList(),
            awaitingResponseIds: stillAwaiting,
            outcome: event.response == RequestResponse.accept
                ? const RequestAcceptedOutcome()
                : const RequestDeclinedOutcome(),
          ),
        );
      case Failure(:final exception):
        emit(
          state.copyWith(
            awaitingResponseIds: stillAwaiting,
            outcome: RequestFailedOutcome(exception),
          ),
        );
    }
  }

  Future<void> _onSent(
    FriendRequestSent event,
    Emitter<FriendRequestsState> emit,
  ) async {
    emit(state.copyWith(isSending: true));

    final result = await _sendFriendRequest(event.email);

    switch (result) {
      case Success():
        emit(
          state.copyWith(isSending: false, outcome: const RequestSentOutcome()),
        );
      case Failure(:final exception):
        emit(
          state.copyWith(
            isSending: false,
            outcome: RequestFailedOutcome(exception),
          ),
        );
    }
  }

  void _onOutcomeCleared(
    FriendRequestsOutcomeCleared event,
    Emitter<FriendRequestsState> emit,
  ) {
    emit(state.copyWith(clearOutcome: true));
  }
}
