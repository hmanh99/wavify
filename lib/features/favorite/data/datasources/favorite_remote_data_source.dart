import 'package:dio/dio.dart';

import '../models/favorite_playlist_response_model.dart';
import '../models/favorite_song_response_model.dart';

class FavoriteApiException implements Exception {
  final String message;
  final int? statusCode;

  const FavoriteApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

abstract class FavoriteRemoteDataSource {
  Future<List<FavoriteSongResponseModel>> getFavoriteSongs({
    int page = 0,
    int size = 50,
  });

  Future<FavoriteSongResponseModel> addFavoriteSong(String songId);

  Future<void> removeFavoriteSong(String songId);

  Future<bool> checkFavoriteSong(String songId);

  Future<Map<String, bool>> checkFavoriteSongs(List<String> songIds);

  Future<List<FavoritePlaylistResponseModel>> getFavoritePlaylists({
    int page = 0,
    int size = 50,
  });

  Future<FavoritePlaylistResponseModel> addFavoritePlaylist(String playlistId);

  Future<void> removeFavoritePlaylist(String playlistId);

  Future<bool> checkFavoritePlaylist(String playlistId);

  Future<Map<String, bool>> checkFavoritePlaylists(List<String> playlistIds);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final Dio dio;

  FavoriteRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FavoriteSongResponseModel>> getFavoriteSongs({
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/favorites/songs',
        queryParameters: {'page': page, 'size': size.clamp(1, 50)},
      );
      final items = _extractPageItems(response.data);
      return items
          .whereType<Map<String, dynamic>>()
          .map(FavoriteSongResponseModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải danh sách bài hát yêu thích');
    }
  }

  @override
  Future<FavoriteSongResponseModel> addFavoriteSong(String songId) async {
    try {
      final response = await dio.post('/api/v1/favorites/songs/$songId');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return FavoriteSongResponseModel.fromJson(data);
      }
      throw const FormatException('Dữ liệu bài hát yêu thích không hợp lệ');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể thêm bài hát vào yêu thích');
    }
  }

  @override
  Future<void> removeFavoriteSong(String songId) async {
    try {
      await dio.delete('/api/v1/favorites/songs/$songId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể bỏ yêu thích bài hát');
    }
  }

  @override
  Future<bool> checkFavoriteSong(String songId) async {
    return _checkSingle(
      '/api/v1/favorites/songs/$songId/check',
      'Không thể kiểm tra trạng thái yêu thích bài hát',
    );
  }

  @override
  Future<Map<String, bool>> checkFavoriteSongs(List<String> songIds) async {
    return _batchCheck(
      '/api/v1/favorites/songs/check',
      songIds,
      'Không thể kiểm tra trạng thái yêu thích bài hát',
    );
  }

  @override
  Future<List<FavoritePlaylistResponseModel>> getFavoritePlaylists({
    int page = 0,
    int size = 50,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/favorites/playlists',
        queryParameters: {'page': page, 'size': size.clamp(1, 50)},
      );
      final items = _extractPageItems(response.data);
      return items
          .whereType<Map<String, dynamic>>()
          .map(FavoritePlaylistResponseModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải danh sách playlist yêu thích');
    }
  }

  @override
  Future<FavoritePlaylistResponseModel> addFavoritePlaylist(
    String playlistId,
  ) async {
    try {
      final response = await dio.post('/api/v1/favorites/playlists/$playlistId');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return FavoritePlaylistResponseModel.fromJson(data);
      }
      throw const FormatException('Dữ liệu playlist yêu thích không hợp lệ');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể thêm playlist vào yêu thích');
    }
  }

  @override
  Future<void> removeFavoritePlaylist(String playlistId) async {
    try {
      await dio.delete('/api/v1/favorites/playlists/$playlistId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể bỏ yêu thích playlist');
    }
  }

  @override
  Future<bool> checkFavoritePlaylist(String playlistId) async {
    return _checkSingle(
      '/api/v1/favorites/playlists/$playlistId/check',
      'Không thể kiểm tra trạng thái yêu thích playlist',
    );
  }

  @override
  Future<Map<String, bool>> checkFavoritePlaylists(
    List<String> playlistIds,
  ) async {
    return _batchCheck(
      '/api/v1/favorites/playlists/check',
      playlistIds,
      'Không thể kiểm tra trạng thái yêu thích playlist',
    );
  }

  Future<bool> _checkSingle(String path, String fallbackError) async {
    try {
      final response = await dio.get(path);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final result = data['result'] ?? data['data'] ?? data;
        if (result is Map<String, dynamic>) {
          return result['favorited'] == true;
        }
      }
      return false;
    } on DioException catch (e) {
      throw _handleDioError(e, fallbackError);
    }
  }

  Future<Map<String, bool>> _batchCheck(
    String path,
    List<String> ids,
    String fallbackError,
  ) async {
    final uniqueIds = ids.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (uniqueIds.isEmpty) return const {};

    final resultMap = <String, bool>{};
    // Backend @Size(max = 100) enforces at most 100 UUIDs per request
    for (var i = 0; i < uniqueIds.length; i += 100) {
      final chunk = uniqueIds.sublist(
        i,
        (i + 100) > uniqueIds.length ? uniqueIds.length : i + 100,
      );
      try {
        final response = await dio.post(path, data: {'ids': chunk});
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final rawResult = data['result'] ?? data['data'] ?? data;
          if (rawResult is Map) {
            for (final entry in rawResult.entries) {
              resultMap[entry.key.toString()] = entry.value == true;
            }
          }
        }
      } on DioException catch (e) {
        throw _handleDioError(e, fallbackError);
      }
    }
    return resultMap;
  }

  List<dynamic> _extractPageItems(dynamic data) {
    if (data is Map<String, dynamic>) {
      final result = data['result'] ?? data['data'];
      if (result is Map<String, dynamic> && result['content'] is List) {
        return result['content'] as List<dynamic>;
      }
      if (result is List) {
        return result;
      }
      if (data['content'] is List) {
        return data['content'] as List<dynamic>;
      }
    } else if (data is List) {
      return data;
    }
    return const [];
  }

  FavoriteApiException _handleDioError(DioException error, String fallback) {
    final status = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return FavoriteApiException(
        'Kết nối quá hạn. Vui lòng kiểm tra server backend đang chạy.',
        statusCode: status,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return FavoriteApiException(
        'Không thể kết nối đến máy chủ (${dio.options.baseUrl}/api/v1/favorites).',
        statusCode: status,
      );
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['msg'];
      if (message != null && message.toString().isNotEmpty) {
        return FavoriteApiException(message.toString(), statusCode: status);
      }
    }

    if (status == 401) {
      return const FavoriteApiException(
        'Bạn cần đăng nhập để thực hiện tính năng này.',
        statusCode: 401,
      );
    } else if (status == 403) {
      return const FavoriteApiException(
        'Bạn không có quyền yêu thích mục riêng tư này.',
        statusCode: 403,
      );
    } else if (status == 404) {
      return const FavoriteApiException(
        'Không tìm thấy mục yêu thích.',
        statusCode: 404,
      );
    }

    return FavoriteApiException(fallback, statusCode: status);
  }
}
