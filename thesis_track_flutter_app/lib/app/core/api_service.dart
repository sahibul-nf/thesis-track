import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';

class ApiConfig {
  static const String _apiBaseUrl =
      'https://thesis-track-production.up.railway.app/api/v1';
  static const String _apiBaseUrlDev = 'http://localhost:8080/api/v1';
  static const String apiTimeout = '15000';

  static String get apiBaseUrl => kDebugMode ? _apiBaseUrlDev : _apiBaseUrl;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final d.Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = d.Dio(
      d.BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: Duration(
          milliseconds: int.parse(
            ApiConfig.apiTimeout,
          ),
        ),
        receiveTimeout: Duration(
          milliseconds: int.parse(
            ApiConfig.apiTimeout,
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

  String _handleError(d.DioException e) {
    switch (e.type) {
      case d.DioExceptionType.connectionTimeout:
      case d.DioExceptionType.sendTimeout:
      case d.DioExceptionType.receiveTimeout:
        return 'Connection timed out';
      case d.DioExceptionType.badResponse:
        var errorMessage = e.response?.data['error'];
        switch (e.response?.statusCode) {
          case 400:
            return errorMessage ?? 'Bad request';
          case 401:
            return errorMessage ?? 'Unauthorized';
          case 403:
            return errorMessage ?? 'Forbidden';
          case 404:
            return errorMessage ?? 'Not found';
          case 500:
            return errorMessage ?? 'Internal server error';
          default:
            return errorMessage ?? 'Server error';
        }
      case d.DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error occurred';
    }
  }
}
