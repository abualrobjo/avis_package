/// Generic Result type for handling success and failure cases in a type-safe manner.
///
/// This is a sealed class implementation of the Either pattern, commonly used
/// in functional programming for error handling without exceptions.
///
/// Example usage:
/// ```dart
/// final result = await fetchUser(id);
/// result.when(
///   success: (user) => print('User: ${user.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
sealed class Result<T, E> {
  const Result();

  /// Returns true if this is a [Success] result.
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is a [Failure] result.
  bool get isFailure => this is Failure<T, E>;

  /// Returns the data if this is a [Success], otherwise null.
  T? get dataOrNull => switch (this) {
    Success<T, E>(:final data) => data,
    Failure<T, E>() => null,
  };

  /// Returns the error if this is a [Failure], otherwise null.
  E? get errorOrNull => switch (this) {
    Success<T, E>() => null,
    Failure<T, E>(:final error) => error,
  };

  /// Pattern matching for handling both success and failure cases.
  ///
  /// Both [success] and [failure] callbacks must be provided.
  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  }) {
    return switch (this) {
      Success<T, E>(:final data) => success(data),
      Failure<T, E>(:final error) => failure(error),
    };
  }

  /// Pattern matching with a default value for the failure case.
  T getOrElse(T Function(E error) orElse) {
    return switch (this) {
      Success<T, E>(:final data) => data,
      Failure<T, E>(:final error) => orElse(error),
    };
  }

  /// Returns the data or throws if this is a [Failure].
  ///
  /// Use with caution - prefer [when] for explicit error handling.
  T getOrThrow() {
    return switch (this) {
      Success<T, E>(:final data) => data,
      Failure<T, E>(:final error) => throw error as Object,
    };
  }

  /// Transforms the success value using the provided [transform] function.
  Result<R, E> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T, E>(:final data) => Success(transform(data)),
      Failure<T, E>(:final error) => Failure(error),
    };
  }

  /// Transforms the error value using the provided [transform] function.
  Result<T, R> mapError<R>(R Function(E error) transform) {
    return switch (this) {
      Success<T, E>(:final data) => Success(data),
      Failure<T, E>(:final error) => Failure(transform(error)),
    };
  }

  /// Chains another Result-returning operation.
  Result<R, E> flatMap<R>(Result<R, E> Function(T data) transform) {
    return switch (this) {
      Success<T, E>(:final data) => transform(data),
      Failure<T, E>(:final error) => Failure(error),
    };
  }
}

/// Represents a successful result containing [data].
final class Success<T, E> extends Result<T, E> {
  /// The success data.
  final T data;

  /// Creates a successful result with [data].
  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T, E> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing an [error].
final class Failure<T, E> extends Result<T, E> {
  /// The error that caused the failure.
  final E error;

  /// Creates a failed result with [error].
  const Failure(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T, E> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extension methods for working with nullable values as Results.
extension ResultExtensions<T> on T? {
  /// Converts a nullable value to a Result.
  ///
  /// Returns [Success] if the value is not null, otherwise [Failure] with [error].
  Result<T, E> toResult<E>(E error) {
    return this != null ? Success(this as T) : Failure(error);
  }
}

/// Extension methods for working with `Future<Result>`.
extension FutureResultExtensions<T, E> on Future<Result<T, E>> {
  /// Maps the success value of a `Future<Result>`.
  Future<Result<R, E>> mapAsync<R>(R Function(T data) transform) async {
    final result = await this;
    return result.map(transform);
  }

  /// Chains another async Result-returning operation.
  Future<Result<R, E>> flatMapAsync<R>(
    Future<Result<R, E>> Function(T data) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T, E>(:final data) => transform(data),
      Failure<T, E>(:final error) => Failure(error),
    };
  }
}
