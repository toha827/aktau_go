import 'package:dio/dio.dart';

import '../../../utils/logger.dart';

class LoggerInterceptor extends Interceptor {
  LoggerInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.response]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  @override
  Future onRequest(RequestOptions options,
      RequestInterceptorHandler handler) async {
    _printRequest(options);

    handler.next(options);
  }

  @override
  Future onError(DioError err,
      ErrorInterceptorHandler handler) async {
    if (error) {
      String message = 'ERROR:';

      message = '$message\n${err.requestOptions.uri}';
      message = '$message\n$err';
      if (err.response != null) {
        message = '$message\n${_getResponseMessage(err.response!)}';
      }
      logger.e(message);

    }
    handler.next(err);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    logger.v(_getResponseMessage(response));

    handler.next(response);
  }

  String _getResponseMessage(Response response) {
    String message = 'Response uri: ${response.requestOptions.uri}';
    if (responseHeader) {
      message = '$message\nstatusCode = ${response.statusCode}';
      if (response.isRedirect == true) {
        message = '$message\nredirect = ${response.realUri}';
      }
      message = '$message\nHEADERS:';
      response.headers.forEach((key, v) {
        message = '$message\n\t$key: $v';
      });
    }
    if (responseBody) {
      message = '$message\nResponse Text:\n${response.toString()}';
    }
    return message;
  }

  void _printRequest(RequestOptions options) {
    String message = 'Request uri: ${options.uri}';

    if (request) {
      message = '$message\n\tmethod: ${options.method}';
      message = '$message\n\tresponseType: ${options.responseType.toString()}';
      message = '$message\n\tfollowRedirects: ${options.followRedirects}';
      message = '$message\n\tconnectTimeout: ${options.connectTimeout}';
      message = '$message\n\treceiveTimeout: ${options.receiveTimeout}';
      message = '$message\n\textra: ${options.extra}';
    }
    if (requestHeader) {
      message = '$message\nHEADERS:';
      options.headers.forEach((key, v) => message = '$message\n\t$key:: $v');
    }
    if (requestBody) {
      message = '$message\n\nDATA:';
      message = '$message\n${options.data.toString()}\n';
    }
    logger.v(message);
  }
}
