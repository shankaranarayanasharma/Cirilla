import 'package:cirilla/constants/app.dart' as acf;
import 'package:cirilla/service/constants/endpoints.dart';
import 'package:cirilla/service/helpers/persist_helper.dart';
import 'package:cirilla/service/helpers/request_helper.dart';
import 'package:cirilla/utils/debug.dart';
import 'package:cirilla/utils/gen_oauth_signature.dart';
import 'package:dio/dio.dart';

abstract class NetworkLocator {
  RequestHelper get providerRequestHelper;
}

class NetworkModule {
  String? defaultCity;
  List<String> list;

  NetworkModule(this.defaultCity, this.list);

  Dio provideDio(PersistHelper sharedPrefHelper) {
    final dio = Dio();
    defaultCity = defaultCity?.toLowerCase();
    defaultCity = defaultCity?.replaceAll(' ', '');

    String baseUrl = acf.baseUrl + (defaultCity ?? "") + '/wp-json';
    String consumerKey = list[0];
    String consumerSecret = list[1];

    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.headers = {'Content-Type': 'application/json; charset=utf-8'}
      ..interceptors.add(LogInterceptor(
        error: false,
        logPrint: (error) => avoidPrint(error),
        request: false,
        requestBody: false,
        requestHeader: false,
        responseHeader: false,
        responseBody: false,
      ))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
            if (options.path.indexOf('/wc/v3/') == 0 ||
                options.path.indexOf('/wc/v2/') == 0) {
              if (baseUrl.indexOf('https://') == 0) {
                options.queryParameters.addAll({
                  "consumer_key": consumerKey,
                  "consumer_secret": consumerSecret,
                });
              } else {
                GenOauthSignature genOauthSignature = GenOauthSignature(
                  consumerKey: consumerKey,
                  url: '$baseUrl${options.path}',
                  consumerKeySecret: consumerSecret,
                  requestMethod: options.method,
                );
                Map<String, String> data =
                    Map<String, String>.of(options.uri.queryParameters);
                Map<String, String> queryParameters =
                    genOauthSignature.generate(data);
                options.queryParameters.addAll(queryParameters);
              }
            } else {
              // getting token
              String? token = sharedPrefHelper.getToken();
              if (token != null) {
                options.headers
                    .putIfAbsent('Authorization', () => 'Bearer $token');
              }
            }

            return handler.next(options);
          },
        ),
      );

    return dio;
  }

  /// A singleton dio_client provider.
  ///
  /// Calling it multiple times will return the same instance.
  DioClient provideDioClient(Dio dio) => DioClient(dio);

  // DI Providers:--------------------------------------------------------------
  /// A singleton preference provider.
  ///
  /// Calling it multiple times will return the same instance.
  RequestHelper provideRequestHelper(DioClient dioClient) =>
      RequestHelper(dioClient);
}

class DioClient {
  // dio instance
  final Dio _dio;

  // injecting dio instance
  DioClient(this._dio);

  // Get: --------------------------------------------------------------------------------------------------------------
  Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  // Post: -------------------------------------------------------------------------------------------------------------
  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  // Delete: -------------------------------------------------------------------------------------------------------------
  Future<dynamic> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioError {
      rethrow;
    }
  }
}
