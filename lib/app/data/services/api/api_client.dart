import 'package:dio/dio.dart';

import 'auth_token_store.dart';

class ApiClient {
  ApiClient(this._tokenStore)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenStore.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final AuthTokenStore _tokenStore;

  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(url, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put<T>(url, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch<T>(url, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(url, data: data, queryParameters: queryParameters);
  }
}
