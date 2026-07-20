import 'dart:async';

import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/watch_session_expiry_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._login,
    this._register,
    this._logout,
    this._checkSession,
    WatchSessionExpiryUseCase watchSessionExpiry,
  ) : super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<_AuthSessionExpired>(_onSessionExpired);

    _expirySubscription =
        watchSessionExpiry().listen((_) => add(const _AuthSessionExpired()));
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final CheckSessionUseCase _checkSession;
  late final StreamSubscription<void> _expirySubscription;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasSession = await _checkSession();
    emit(
      hasSession
          ? const AuthState.authenticated()
          : const AuthState.unauthenticated(),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.unauthenticated(isSubmitting: true));
    try {
      final user = await _login(email: event.email, password: event.password);
      emit(AuthState.authenticated(user));
    } on AppException catch (failure) {
      emit(AuthState.unauthenticated(failure: failure));
    }
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.unauthenticated(isSubmitting: true));
    try {
      final user = await _register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthState.authenticated(user));
    } on AppException catch (failure) {
      emit(AuthState.unauthenticated(failure: failure));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthState.unauthenticated());
  }

  void _onSessionExpired(
    _AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState.unauthenticated());
  }

  @override
  Future<void> close() async {
    await _expirySubscription.cancel();
    return super.close();
  }
}
