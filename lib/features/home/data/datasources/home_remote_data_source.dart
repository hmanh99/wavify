import 'package:dio/dio.dart';

import '../models/song_response_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<SongResponseModel>> getAllSongs({int page = 0, int size = 50});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SongResponseModel>> getAllSongs({int page = 0, int size = 50}) async {
    try {
      final response = await dio.get(
        '/api/v1/songs',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final dynamic data = response.data;
      List<dynamic> items = [];

      if (data is Map<String, dynamic>) {
        final result = data['result'] ?? data['data'];
        if (result is Map<String, dynamic>) {
          if (result.containsKey('content') && result['content'] is List) {
            items = result['content'] as List<dynamic>;
          }
        } else if (result is List) {
          items = result;
        } else if (data.containsKey('content') && data['content'] is List) {
          items = data['content'] as List<dynamic>;
        }
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => SongResponseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải danh sách bài hát');
    }
  }

  Exception _handleDioError(DioException error, String fallback) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Kết nối quá hạn. Vui lòng kiểm tra server backend đang chạy.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception(
        'Không thể kết nối đến máy chủ (${dio.options.baseUrl}/api/v1/songs).',
      );
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['msg'];
      if (message != null && message.toString().isNotEmpty) {
        return Exception(message.toString());
      }
    }

    final status = error.response?.statusCode;
    if (status == 401) {
      return Exception('Phiên đăng nhập đã hết hạn. Vui lòng thử lại.');
    } else if (status == 403) {
      return Exception('Bạn không có quyền truy cập danh sách này.');
    } else if (status == 404) {
      return Exception('Không tìm thấy danh sách bài hát ($status).');
    }

    return Exception(fallback);
  }
}
