import 'package:dio/dio.dart' as d;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final d.Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = d.Dio(
      d.BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
        connectTimeout: Duration(
          milliseconds: int.parse(
            dotenv.env['API_TIMEOUT'] ?? '30000',
          ),
        ),
        receiveTimeout: Duration(
          milliseconds: int.parse(
            dotenv.env['API_TIMEOUT'] ?? '30000',
          ),
        ),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );

    // Add auth interceptor
    dio.interceptors.add(
      d.InterceptorsWrapper(
        onRequest: (options, handler) {
          // Get token from storage and add to header
          final token = StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (d.DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle token expiration
            StorageService.clearAuthData();
            Get.offAllNamed('/login');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<d.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    d.Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on d.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<d.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d.Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on d.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<d.Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d.Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on d.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<d.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d.Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on d.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(d.DioException e) {
    switch (e.type) {
      case d.DioExceptionType.connectionTimeout:
      case d.DioExceptionType.sendTimeout:
      case d.DioExceptionType.receiveTimeout:
        return Exception('Connection timed out');
      case d.DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            return Exception('Bad request');
          case 401:
            return Exception('Unauthorized');
          case 403:
            return Exception('Forbidden');
          case 404:
            return Exception('Not found');
          case 500:
            return Exception('Internal server error');
          default:
            return Exception('Server error');
        }
      case d.DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error occurred');
    }
  }
}
