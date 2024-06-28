import 'package:base_framework/common/network/api_result.dart';
import 'package:dio/dio.dart';

abstract class ApiHelper<T> {
  late final T data;

  Future<ApiResult> makeApiCall(Future<Response<dynamic>> apiCallback) async {
    final Response response = await apiCallback;
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! <= 229) {
      return ApiResult.success(data);
    } else {
      return ApiResult.failure(response.statusMessage ?? "");
    }
  }
}
