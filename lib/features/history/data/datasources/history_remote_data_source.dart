import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<void> recordHistory(String songId);
  Future<List<HistoryModel>> getHistory({int page = 0, int size = 20});
  Future<void> clearHistory();
  Future<void> deleteHistoryItem(String historyId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;

  HistoryRemoteDataSourceImpl({required this.dio});

  /// POST /api/v1/history
  /// Request body: `{"songId": "<UUID>"}`
  /// Response: `ApiResponse<PlayHistoryResponse>` with 201 Created
  @override
  Future<void> recordHistory(String songId) async {
    try {
      await dio.post(
        '/api/v1/history',
        data: {
          'songId': songId,
        },
      );
    } on DioException catch (e) {
      debugPrint('[HistoryRemoteDataSource] recordHistory failed: $e');
      throw _handleDioError(e, 'Không thể ghi nhận lịch sử nghe nhạc');
    }
  }

  /// GET /api/v1/history?page={page}&size={size}
  /// Response: `ApiResponse<Page<PlayHistoryResponse>>` with 200 OK
  @override
  Future<List<HistoryModel>> getHistory({int page = 0, int size = 20}) async {
    try {
      final response = await dio.get(
        '/api/v1/history',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final dynamic data = response.data;
      List<dynamic> items = [];

      if (data is Map<String, dynamic>) {
        final result = data['result'] ?? data['data'];
        if (result is Map<String, dynamic> &&
            result.containsKey('content') &&
            result['content'] is List) {
          // Spring Data Page<PlayHistoryResponse>
          items = result['content'] as List<dynamic>;
        } else if (result is List) {
          items = result;
        } else if (data.containsKey('content') && data['content'] is List) {
          items = data['content'] as List<dynamic>;
        }
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => HistoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải lịch sử phát nhạc');
    }
  }

  /// DELETE /api/v1/history
  /// Clears entire user play history
  @override
  Future<void> clearHistory() async {
    try {
      await dio.delete('/api/v1/history');
    } on DioException catch (e) {
      debugPrint('[HistoryRemoteDataSource] clearHistory failed: $e');
      throw _handleDioError(e, 'Không thể xóa lịch sử nghe nhạc');
    }
  }

  /// DELETE /api/v1/history/{historyId}
  /// Deletes a single history record of current user
  @override
  Future<void> deleteHistoryItem(String historyId) async {
    try {
      await dio.delete('/api/v1/history/$historyId');
    } on DioException catch (e) {
      debugPrint('[HistoryRemoteDataSource] deleteHistoryItem failed: $e');
      throw _handleDioError(e, 'Không thể xóa bài hát khỏi lịch sử');
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
        'Không thể kết nối đến máy chủ (${dio.options.baseUrl}/api/v1/history).',
      );
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['msg'];
      if (message != null && message.toString().isNotEmpty) {
        return Exception(message.toString());
      }
    }

    return Exception(fallback);
  }
}
