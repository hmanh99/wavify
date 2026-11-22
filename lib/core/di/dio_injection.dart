import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'service_locator.dart';

Future<void> initDioDependencies({
  String? baseUrl,
  Dio? customDio,
}) async {
  final rawBaseUrl =
      (baseUrl != null && baseUrl.isNotEmpty) ? baseUrl : ApiConstants.baseUrl;
  final resolvedBaseUrl = rawBaseUrl.endsWith('/')
      ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
      : rawBaseUrl;

  final baseOptions = BaseOptions(
    baseUrl: resolvedBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  // Dedicated clean Dio for token refresh & rotation
  if (!sl.isRegistered<Dio>(instanceName: 'refreshDio')) {
    final refreshDio = Dio(baseOptions);
    sl.registerLazySingleton<Dio>(
      () => refreshDio,
      instanceName: 'refreshDio',
    );
  }

  // Main Dio instance
  if (!sl.isRegistered<Dio>()) {
    final mainDio = customDio ?? Dio(baseOptions);
    if (customDio != null && mainDio.options.baseUrl.isEmpty) {
      mainDio.options.baseUrl = resolvedBaseUrl;
    }
    sl.registerLazySingleton<Dio>(() => mainDio);
  }
}
