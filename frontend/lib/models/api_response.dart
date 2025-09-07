class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(ApiError error) {
    return ApiResponse(
      success: false,
      error: error,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    if (json['success'] == true) {
      return ApiResponse.success(
        fromJson(json['data']),
        message: json['message'],
      );
    } else {
      return ApiResponse.error(
        ApiError.fromJson(json['error'] ?? {}),
      );
    }
  }
}

class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final ErrorType type;

  ApiError({
    required this.code,
    required this.message,
    this.details,
    required this.type,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'],
      type: _getErrorTypeFromCode(json['code'] ?? 'UNKNOWN_ERROR'),
    );
  }

  factory ApiError.network(String message) {
    return ApiError(
      code: 'NETWORK_ERROR',
      message: message,
      type: ErrorType.network,
    );
  }

  factory ApiError.authentication(String message) {
    return ApiError(
      code: 'AUTH_ERROR',
      message: message,
      type: ErrorType.authentication,
    );
  }

  factory ApiError.validation(String message, {Map<String, dynamic>? details}) {
    return ApiError(
      code: 'VALIDATION_ERROR',
      message: message,
      details: details,
      type: ErrorType.validation,
    );
  }

  factory ApiError.server(String message) {
    return ApiError(
      code: 'SERVER_ERROR',
      message: message,
      type: ErrorType.server,
    );
  }

  static ErrorType _getErrorTypeFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'NETWORK_ERROR':
      case 'TIMEOUT_ERROR':
      case 'CONNECTION_ERROR':
        return ErrorType.network;
      case 'AUTH_ERROR':
      case 'UNAUTHORIZED':
      case 'TOKEN_EXPIRED':
        return ErrorType.authentication;
      case 'VALIDATION_ERROR':
      case 'INVALID_INPUT':
        return ErrorType.validation;
      case 'SERVER_ERROR':
      case 'INTERNAL_SERVER_ERROR':
        return ErrorType.server;
      default:
        return ErrorType.unknown;
    }
  }
}

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  unknown,
}