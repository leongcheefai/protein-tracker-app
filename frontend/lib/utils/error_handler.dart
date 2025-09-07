import 'package:flutter/cupertino.dart';
import '../models/api_response.dart';

class ErrorHandler {
  static void handleApiError(
    ApiError error, 
    BuildContext context, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    switch (error.type) {
      case ErrorType.network:
        _handleNetworkError(context, error, customMessage, onRetry);
        break;
        
      case ErrorType.authentication:
        _handleAuthenticationError(context, error);
        break;
        
      case ErrorType.validation:
        _handleValidationError(context, error, customMessage);
        break;
        
      case ErrorType.server:
        _handleServerError(context, error, customMessage);
        break;
        
      case ErrorType.unknown:
        _handleUnknownError(context, error, customMessage);
        break;
    }
  }

  static void _handleNetworkError(
    BuildContext context,
    ApiError error,
    String? customMessage,
    VoidCallback? onRetry,
  ) {
    // For critical network errors, show alert for now
    // TODO: Navigate to dedicated error screen once created
    if (error.code == 'CONNECTION_ERROR' || error.code == 'TIMEOUT_ERROR') {
      // For minor network issues, show alert dialog
      _showErrorDialog(
        context,
        title: 'Connection Issue',
        message: customMessage ?? error.message,
        primaryAction: CupertinoDialogAction(
          child: const Text('Retry'),
          onPressed: () {
            Navigator.of(context).pop();
            onRetry?.call();
          },
        ),
        secondaryAction: CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  static void _handleAuthenticationError(BuildContext context, ApiError error) {
    // TODO: Clear authentication state and navigate to login once provider is available
    
    if (error.code == 'TOKEN_EXPIRED') {
      _showErrorDialog(
        context,
        title: 'Session Expired',
        message: 'Your session has expired. Please sign in again.',
        primaryAction: CupertinoDialogAction(
          child: const Text('Sign In'),
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: Navigate to authentication screen once available
          },
        ),
      );
    } else {
      _showErrorDialog(
        context,
        title: 'Authentication Required',
        message: error.message,
        primaryAction: CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  static void _handleValidationError(
    BuildContext context,
    ApiError error,
    String? customMessage,
  ) {
    String message = customMessage ?? error.message;
    
    // If we have detailed validation errors, format them nicely
    if (error.details != null) {
      final details = error.details!;
      if (details['fields'] != null) {
        final fieldErrors = List<String>.from(details['fields']);
        message = fieldErrors.join('\n');
      }
    }

    _showErrorDialog(
      context,
      title: 'Invalid Input',
      message: message,
      primaryAction: CupertinoDialogAction(
        child: const Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  static void _handleServerError(
    BuildContext context,
    ApiError error,
    String? customMessage,
  ) {
    _showErrorDialog(
      context,
      title: 'Server Error',
      message: customMessage ?? 'Something went wrong on our end. Please try again later.',
      primaryAction: CupertinoDialogAction(
        child: const Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  static void _handleUnknownError(
    BuildContext context,
    ApiError error,
    String? customMessage,
  ) {
    _showErrorDialog(
      context,
      title: 'Unexpected Error',
      message: customMessage ?? 'An unexpected error occurred. Please try again.',
      primaryAction: CupertinoDialogAction(
        child: const Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  static void _showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    required CupertinoDialogAction primaryAction,
    CupertinoDialogAction? secondaryAction,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (secondaryAction != null) secondaryAction,
          primaryAction,
        ],
      ),
    );
  }

  // Helper method for handling API responses with automatic error handling
  static Future<T?> handleApiResponse<T>(
    Future<ApiResponse<T>> apiCall,
    BuildContext context, {
    String? customErrorMessage,
    VoidCallback? onRetry,
    bool showSuccessMessage = false,
    String? successMessage,
  }) async {
    try {
      final response = await apiCall;
      
      if (response.success && response.data != null) {
        if (showSuccessMessage && response.message != null) {
          _showSuccessMessage(context, successMessage ?? response.message!);
        }
        return response.data;
      } else if (response.error != null) {
        handleApiError(
          response.error!,
          context,
          customMessage: customErrorMessage,
          onRetry: onRetry,
        );
        return null;
      } else {
        handleApiError(
          ApiError.server('Unknown error occurred'),
          context,
          customMessage: customErrorMessage,
          onRetry: onRetry,
        );
        return null;
      }
    } catch (e) {
      handleApiError(
        ApiError.server(e.toString()),
        context,
        customMessage: customErrorMessage,
        onRetry: onRetry,
      );
      return null;
    }
  }

  static void _showSuccessMessage(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Handle permission errors specifically
  static void handlePermissionError(
    BuildContext context,
    String permission, {
    VoidCallback? onRetry,
  }) {
    // TODO: Navigate to dedicated permission screen once created
    _showErrorDialog(
      context,
      title: 'Permission Required',
      message: 'This app needs $permission permission to function properly.',
      primaryAction: CupertinoDialogAction(
        child: const Text('Retry'),
        onPressed: () {
          Navigator.of(context).pop();
          onRetry?.call();
        },
      ),
      secondaryAction: CupertinoDialogAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Show loading overlay with error handling
  static Future<T?> showLoadingOverlay<T>(
    BuildContext context,
    Future<ApiResponse<T>> future, {
    String loadingMessage = 'Loading...',
    String? customErrorMessage,
    VoidCallback? onRetry,
  }) async {
    // Show loading dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 16),
            Text(loadingMessage),
          ],
        ),
      ),
    );

    try {
      final result = await handleApiResponse(
        future,
        context,
        customErrorMessage: customErrorMessage,
        onRetry: onRetry,
      );

      // Dismiss loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return result;
    } catch (e) {
      // Dismiss loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      rethrow;
    }
  }

  // Retry wrapper for API calls
  static Future<ApiResponse<T>> withRetry<T>(
    Future<ApiResponse<T>> Function() apiCall, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    ApiResponse<T>? lastResponse;
    
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        lastResponse = await apiCall();
        
        if (lastResponse.success || 
            (lastResponse.error?.type != ErrorType.network &&
             lastResponse.error?.type != ErrorType.server)) {
          return lastResponse;
        }
        
        if (attempt < maxRetries) {
          await Future.delayed(delay * (attempt + 1));
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return ApiResponse.error(ApiError.server(e.toString()));
        }
        await Future.delayed(delay * (attempt + 1));
      }
    }
    
    return lastResponse ?? ApiResponse.error(ApiError.server('Max retries exceeded'));
  }
}