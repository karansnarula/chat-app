import 'package:chat_app/core/error/app_exception.dart';

/// Typed outcome of an operation that can fail.
///
/// Being sealed, a `switch` over a [Result] is compiler-checked for
/// exhaustiveness — callers cannot forget the failure path:
///
/// ```dart
/// switch (await login(...)) {
///   case Success(:final value): // use value
///   case Failure(:final exception): // handle exception
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.exception);

  final AppException exception;
}
