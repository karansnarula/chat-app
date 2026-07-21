part of 'chats_bloc.dart';

sealed class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load; shows the loading skeleton.
final class ChatsRequested extends ChatsEvent {
  const ChatsRequested();
}

/// Pull-to-refresh; keeps the current list visible while fetching.
final class ChatsRefreshed extends ChatsEvent {
  const ChatsRefreshed();
}
