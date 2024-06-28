import 'dart:developer';

import 'package:base_framework/common/local/token_manager.dart';
import 'package:base_framework/common/network/api_config.dart';
import 'package:base_framework/di.dart';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_logging_interceptor.dart';

//Api client for non auth login APIs
class ApiClient {
  final Dio dio = createDio();

  ApiClient._internal();

  static final _singleton = ApiClient._internal();

  factory ApiClient() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      receiveTimeout: 15000,
      connectTimeout: 15000,
      sendTimeout: 15000,
    ));

    dio.interceptors.addAll([ApiLoggingInterceptor(), AppInterceptors(dio)]);

    return dio;
  }
}

//Api client for auth API calls
class AuthApiClient {
  final Dio dio = createDio();

  AuthApiClient._internal();

  static final _singleton = AuthApiClient._internal();

  factory AuthApiClient() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        receiveTimeout: 15000,
        connectTimeout: 15000,
        sendTimeout: 15000));

    dio.interceptors.addAll([
      ApiLoggingInterceptor(),
      RefreshApiInterceptor(dio),
      AuthAppInterceptors(dio),
    ]);

    return dio;
  }
}

//Api client for auth API calls
class ApiClientStatic {
  final Dio dio = createDio();

  ApiClientStatic._internal();

  static final _singleton = ApiClientStatic._internal();

  factory ApiClientStatic() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
        baseUrl: ApiConfig.staticAPIBaseUrl,
        receiveTimeout: 15000,
        connectTimeout: 15000,
        sendTimeout: 15000));

    dio.interceptors.addAll([ApiLoggingInterceptor(), AppInterceptors(dio)]);

    return dio;
  }
}

class AppInterceptors extends Interceptor {
  final Dio dio;

  AppInterceptors(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var token = ApiConfig.token;

    options.headers['Authorization'] = 'bearer $token';
    options.headers['content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    handleApiErrors(err);
    return handler.next(err);
  }
}

class AuthAppInterceptors extends Interceptor {
  final Dio dio;

  AuthAppInterceptors(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var preference = await SharedPreferences.getInstance();

    options.headers['Authorization'] =
        'bearer ${preference.getString("token")}';
        log('bearer ${preference.getString("token")}');
      
    options.headers['content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    handleApiErrors(err);
    return handler.next(err);
  }
}

class RefreshApiInterceptor extends Interceptor {
  bool navigateToLoginScreen = false;
 
  TokenManager tokenManager = getIt<TokenManager>();
  final Dio dio;

  RefreshApiInterceptor(this.dio);
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      navigateToLoginScreen = false;
      // If a 401 response is received, refresh the access token

      String newAccessToken = await refreshToken();
      //save token
      await saveToken(tokenManager, newAccessToken);
      var preference = await SharedPreferences.getInstance();
      // Update the request header with the new access token
      err.requestOptions.headers['Authorization'] =
          'bearer ${preference.getString("token")}';
      err.requestOptions.headers['content-Type'] = 'application/json';
      // Repeat the request with the updated header

      return handler.resolve(await dio.fetch(err.requestOptions));
    }
    return handler.next(err);
  }

  refreshToken() async {
    try {
      String refreshToken ="";
      return refreshToken;
         
    } on DioError catch (e) {
      e.requestOptions.cancelToken;
      //navigate to appropriate location
    }
  }

  Future<void> saveToken(TokenManager tokenManager, String token) async {
    await tokenManager.saveToken(token);
  }

  
}

void handleApiErrors(DioError err) {
  switch (err.type) {
    case DioErrorType.connectTimeout:
    case DioErrorType.sendTimeout:
    case DioErrorType.receiveTimeout:
      throw DeadlineExceededException(err.requestOptions);
    case DioErrorType.response:
      switch (err.response?.statusCode) {
        case 400:
          throw BadRequestException(err.requestOptions);
        case 401:
          throw UnauthorizedException(err.requestOptions);
        case 404:
          throw NotFoundException(err.requestOptions);
        case 409:
          throw ConflictException(err.requestOptions, err.response!.data);
        case 500:
          throw InternalServerErrorException(err.requestOptions);
        case 406:
          throw InvalidDataException(err.requestOptions, err.response!.data);
        case 503:
          throw ServerDownException(err.requestOptions);
        case 504:
          throw GatewayTimeoutException(err.requestOptions);
        case 502:
          throw ServerDownException(err.requestOptions);
      }
      break;
    case DioErrorType.cancel:
      break;
    case DioErrorType.other:
      throw NoInternetConnectionException(err.requestOptions);
  }
}

class InvalidDataException extends DioError {
  InvalidDataException(RequestOptions r, this.data) : super(requestOptions: r);
  final dynamic data;
  @override
  String toString() {
  

    return "Not Acceptable";
  }
}

class BadRequestException extends DioError {
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioError {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, Please try again later';
  }
}

class ServerDownException extends DioError {
  ServerDownException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return "Service temporarily unavailable,Please try again later";
  }
}

class GatewayTimeoutException extends DioError {
  GatewayTimeoutException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return "Gateway Time-out,please try again";
  }
}

class ConflictException extends DioError {
  final dynamic data;
  ConflictException(RequestOptions r, this.data) : super(requestOptions: r);

  @override
  String toString() {
   return "Conflict Occured";
  }
}

class UnauthorizedException extends DioError {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioError {
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioError {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class DeadlineExceededException extends DioError {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}
