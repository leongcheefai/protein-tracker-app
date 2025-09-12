import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';

class ApiService {
  static String get baseUrl {
    // Try to get from environment variable first
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Platform-specific defaults
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isIOS) {
      // For iOS Simulator, use 127.0.0.1 instead of localhost
      return 'http://127.0.0.1:3000/api';
    } else if (Platform.isAndroid) {
      // For Android emulator, use 10.0.2.2 to reach host machine
      return 'http://10.0.2.2:3000/api';
    } else {
      // Default for other platforms
      return 'http://localhost:3000/api';
    }
  }
  
  static const String _tokenKey = 'auth_token';
  
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Connectivity _connectivity = Connectivity();
  
  String? _authToken;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _setupInterceptors();
    
    // Load any existing auth token from secure storage
    _initializeToken();
  }
  
  Future<void> _initializeToken() async {
    try {
      await loadAuthToken();
    } catch (e) {
      // If loading token fails, continue without it
    }
  }
  
  void _setupInterceptors() {
    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          await _handleTokenExpiry();
        }
        handler.next(error);
      },
    ));
    
    // Logging interceptor for debugging (development only)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        // TODO: Replace with proper logging framework in production
        // ignore: avoid_print
        print('[API] $obj');
      },
    ));
  }
  
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<void> loadAuthToken() async {
    _authToken = await _storage.read(key: _tokenKey);
  }
  
  Future<String?> getStoredToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  String? get currentToken => _authToken;
  
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _storage.delete(key: _tokenKey);
  }
  
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      if (!await isOnline()) {
        return ApiResponse.error(ApiError.network('No internet connection'));
      }
      
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      // Handle specific network profiling errors
      if (e.toString().contains('network_profiling')) {
        return ApiResponse.error(ApiError.network('Network profiling error - continuing with request'));
      }
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      if (!await isOnline()) {
        return ApiResponse.error(ApiError.network('No internet connection'));
      }
      
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      // Handle specific network profiling errors
      if (e.toString().contains('network_profiling')) {
        return ApiResponse.error(ApiError.network('Network profiling error - continuing with request'));
      }
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> data, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      if (!await isOnline()) {
        return ApiResponse.error(ApiError.network('No internet connection'));
      }
      
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      if (!await isOnline()) {
        return ApiResponse.error(ApiError.network('No internet connection'));
      }
      
      final response = await _dio.delete(endpoint);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    Map<String, dynamic>? additionalData,
    T Function(Map<String, dynamic>)? fromJson,
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      if (!await isOnline()) {
        return ApiResponse.error(ApiError.network('No internet connection'));
      }
      
      final formData = FormData();
      
      // Add file
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(file.path),
      ));
      
      // Add additional data
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }
      
      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }
  
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data;
    
    if (data is Map<String, dynamic>) {
      if (data['success'] == true) {
        if (fromJson != null && data['data'] != null) {
          // Ensure data['data'] is a Map before passing to fromJson
          if (data['data'] is Map<String, dynamic>) {
            final parsedData = fromJson(data['data']);
            return ApiResponse.success(parsedData, message: data['message']);
          } else {
            return ApiResponse.error(ApiError.server('Invalid data format in response'));
          }
        } else if (fromJson != null && data['data'] == null) {
          // Handle null data when fromJson is expected
          return ApiResponse.error(ApiError.server('No data available'));
        } else {
          return ApiResponse.success(data['data'] as T, message: data['message']);
        }
      } else {
        return ApiResponse.error(ApiError.fromJson(data['error'] ?? {}));
      }
    }
    
    return ApiResponse.error(ApiError.server('Invalid response format'));
  }
  
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error(ApiError.network('Connection timeout'));
        
        case DioExceptionType.connectionError:
          return ApiResponse.error(ApiError.network('Connection error'));
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (statusCode == 401) {
            return ApiResponse.error(ApiError.authentication('Authentication required'));
          } else if (statusCode == 422 || statusCode == 400) {
            final message = data is Map ? data['message'] ?? 'Validation error' : 'Validation error';
            return ApiResponse.error(ApiError.validation(message, details: data));
          } else if (statusCode != null && statusCode >= 500) {
            return ApiResponse.error(ApiError.server('Server error'));
          }
          
          return ApiResponse.error(ApiError.server('Request failed'));
        
        case DioExceptionType.cancel:
          return ApiResponse.error(ApiError.network('Request cancelled'));
        
        case DioExceptionType.unknown:
          return ApiResponse.error(ApiError.network('Network error'));
        
        default:
          return ApiResponse.error(ApiError.server('Unknown error occurred'));
      }
    }
    
    return ApiResponse.error(ApiError.server(error.toString()));
  }
  
  Future<void> _handleTokenExpiry() async {
    // Clear expired token
    await clearAuthToken();
    // Note: In a real app, you might want to trigger a token refresh here
    // or navigate to the login screen
  }
}