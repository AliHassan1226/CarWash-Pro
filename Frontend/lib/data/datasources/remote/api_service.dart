// Remote API service

import 'package:dio/dio.dart';
import 'package:car_wash_app/core/constants/api_endpoints.dart';
import 'package:car_wash_app/core/constants/app_constants.dart';
import 'package:logger/logger.dart';

class ApiService {
  late Dio _dio;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
              'API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _logger.e('API Error: ${error.message} ${error.requestOptions.path}');
          return handler.next(error);
        },
      ),
    );
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      _logger.e('GET Error: $e');
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      _logger.e('POST Error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      _logger.e('PUT Error: $e');
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      _logger.e('PATCH Error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers, required Map<String, String> data,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      _logger.e('DELETE Error: $e');
      rethrow;
    }
  }

  // File upload
  Future<Response> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
      );
      return response;
    } on DioException catch (e) {
      _logger.e('Upload Error: $e');
      rethrow;
    }
  }

  // Multiple file upload
  Future<Response> uploadMultipleFiles(
    String endpoint, {
    required List<String> filePaths,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final List<MultipartFile> files = [];
      for (final filePath in filePaths) {
        files.add(await MultipartFile.fromFile(filePath));
      }

      final formData = FormData.fromMap({
        fieldName: files,
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
      );
      return response;
    } on DioException catch (e) {
      _logger.e('Multiple Upload Error: $e');
      rethrow;
    }
  }
}
