part of 'friend_requests_bloc.dart';

enum FriendRequestsStatus { loading, success, failure }

/// One-shot result of an action, surfaced as a snackbar and then cleared.
sealed class RequestOutcome extends Equatable {
  const RequestOutcome();

  @override
  List<Object?> get props => [];
}

final class RequestSentOutcome extends RequestOutcome {
  const RequestSentOutcome();
}

final class RequestAcceptedOutcome extends RequestOutcome {
  const RequestAcceptedOutcome();
}

final class RequestDeclinedOutcome extends RequestOutcome {
  const RequestDeclinedOutcome();
}

final class RequestFailedOutcome extends RequestOutcome {
  const RequestFailedOutcome(this.exception);

  final AppException exception;

  @override
  List<Object?> get props => [exception];
}

class FriendRequestsState extends Equatable {
  const FriendRequestsState({
    this.status = FriendRequestsStatus.loading,
    this.requests = const [],
    this.awaitingResponseIds = const {},
    this.failure,
    this.outcome,
    this.isSending = false,
  });

  final FriendRequestsStatus status;
  final List<FriendRequest> requests;

  /// Requests with an accept/decline call in flight.
  final Set<String> awaitingResponseIds;
  final AppException? failure;
  final RequestOutcome? outcome;
  final bool isSending;

  int get pendingCount => requests.length;

  bool get hasPending => requests.isNotEmpty;

  bool get isEmpty =>
      status == FriendRequestsStatus.success && requests.isEmpty;

  FriendRequestsState copyWith({
    FriendRequestsStatus? status,
    List<FriendRequest>? requests,
    Set<String>? awaitingResponseIds,
    AppException? failure,
    RequestOutcome? outcome,
    bool? isSending,
    bool clearFailure = false,
    bool clearOutcome = false,
  }) {
    return FriendRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      awaitingResponseIds: awaitingResponseIds ?? this.awaitingResponseIds,
      failure: clearFailure ? null : failure ?? this.failure,
      outcome: clearOutcome ? null : outcome ?? this.outcome,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requests,
        awaitingResponseIds,
        failure,
        outcome,
        isSending,
      ];
}
