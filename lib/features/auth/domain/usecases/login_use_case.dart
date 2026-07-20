import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Orchestrates login. Will grow socket connect + FCM token registration
/// when those services land in later phases.
@injectable
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}
