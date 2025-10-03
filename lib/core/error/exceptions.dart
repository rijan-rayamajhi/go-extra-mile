/// Custom exceptions for the application
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown when a user account has been deleted
class AccountDeletedException extends AppException {
  AccountDeletedException()
    : super(
        'Your account has been deleted. Please contact support for further assistance.',
        code: 'ACCOUNT_DELETED',
      );
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException(super.message) : super(code: 'AUTH_FAILED');
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  NetworkException(super.message) : super(code: 'NETWORK_ERROR');
}

/// Exception thrown when data operations fail
class DataException extends AppException {
  DataException(super.message) : super(code: 'DATA_ERROR');
}

/// Exception thrown when database operations fail
class DatabaseException extends AppException {
  DatabaseException(super.message) : super(code: 'DATABASE_ERROR');
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  CacheException(super.message) : super(code: 'CACHE_ERROR');
}

/// Exception thrown when server operations fail
class ServerException extends AppException {
  ServerException(super.message) : super(code: 'SERVER_ERROR');
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  NotFoundException(super.message) : super(code: 'NOT_FOUND');
}
