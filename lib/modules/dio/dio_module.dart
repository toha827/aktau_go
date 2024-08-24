import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/env.dart';
import '../flavor/flavor.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/exception_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

const _timeout = 30;

@module
abstract class DioModule {
  @lazySingleton
  Dio getDio(
    Flavor flavor,
  ) {
    final dio = Dio();
    return dio
      ..options.baseUrl = flavor.baseApiUrl
      // здесь позже так же можно будет добавить auth interceptor или логирование
      ..options.headers['accept'] = 'application/json'

      /// TODO сделать изменяемым для отправки разных данных
      ..options.headers['Content-Type'] = 'application/json'
      ..options.connectTimeout = const Duration(seconds: _timeout)
      ..options.sendTimeout = const Duration(seconds: _timeout)
      ..options.receiveTimeout = const Duration(seconds: _timeout)
      ..interceptors.addAll(
        [
          authInterceptors(dio),
          LoggerInterceptor(
            requestBody: true,
            responseBody: true,
          ),
          ExceptionInterceptor(),
        ],
      );
  }
}

@singleton
class DioInteractor {
  final Dio dio;

  DioInteractor(this.dio);

  Future<Response<Map<String, dynamic>>> fetch({
    required String url,
    required String method,
    ResponseType responseType = ResponseType.json,
    FormData? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.fetch<Map<String, dynamic>>(
      Options(
        method: method,
        responseType: ResponseType.json,
        contentType: 'multipart/form-data',
        // validateStatus: (status) {
        //   status ??= 500;
        //   return status >= 200 && status < 300;
        // },
      )
          .compose(
            dio.options,
            url,
            data: data,
            queryParameters: queryParameters,
          )
          .copyWith(baseUrl: devBaseApiUrl),
    );
  }
}
