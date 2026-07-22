part of 'friend_requests_bloc.dart';

sealed class FriendRequestsEvent extends Equatable {
  const FriendRequestsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load; shows the loading state.
final class FriendRequestsRequested extends FriendRequestsEvent {
  const FriendRequestsRequested();
}

/// Re-fetch that keeps the current list visible.
final class FriendRequestsRefreshed extends FriendRequestsEvent {
  const FriendRequestsRefreshed();
}

final class FriendRequestResponded extends FriendRequestsEvent {
  const FriendRequestResponded({
    required this.requestId,
    required this.response,
  });

  final String requestId;
  final RequestResponse response;

  @override
  List<Object?> get props => [requestId, response];
}

final class FriendRequestSent extends FriendRequestsEvent {
  const FriendRequestSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Clears a one-shot outcome after the UI has shown it.
final class FriendRequestsOutcomeCleared extends FriendRequestsEvent {
  const FriendRequestsOutcomeCleared();
}
