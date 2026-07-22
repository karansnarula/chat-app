import 'package:equatable/equatable.dart';

class FriendRequest extends Equatable {
  const FriendRequest({
    required this.id,
    required this.sender,
    required this.createdAt,
  });

  final String id;
  final RequestSender sender;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, sender, createdAt];
}

class RequestSender extends Equatable {
  const RequestSender({
    required this.id,
    required this.displayName,
    required this.email,
  });

  final String id;
  final String displayName;
  final String email;

  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  @override
  List<Object?> get props => [id, displayName, email];
}

enum RequestResponse { accept, decline }
