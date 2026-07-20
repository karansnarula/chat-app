part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.failure,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  /// [user] is null when a stored session was restored at startup —
  /// the profile is fetched lazily via `/users/me` where needed.
  const AuthState.authenticated([AuthUser? user])
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated({
    bool isSubmitting = false,
    AppException? failure,
  }) : this._(
          status: AuthStatus.unauthenticated,
          isSubmitting: isSubmitting,
          failure: failure,
        );

  final AuthStatus status;
  final AuthUser? user;
  final bool isSubmitting;
  final AppException? failure;

  @override
  List<Object?> get props => [status, user, isSubmitting, failure];
}
