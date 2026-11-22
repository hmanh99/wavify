import 'package:dio/dio.dart';

import '../models/create_playlist_request_model.dart';
import '../models/playlist_model.dart';
import '../models/song_response_model.dart';
import '../models/update_playlist_request_model.dart';

abstract class PlaylistRemoteDataSource {
  Future<List<PlaylistModel>> getMyPlaylists();

  Future<PlaylistModel> getPlaylistById(String playlistId);

  Future<List<SongResponseModel>> getAllSongs({int page = 0, int size = 50});

  Future<PlaylistModel> createPlaylist(CreatePlaylistRequestModel request);

  Future<PlaylistModel> updatePlaylist(String playlistId, UpdatePlaylistRequestModel request);

  Future<void> deletePlaylist(String playlistId);

  Future<PlaylistModel> addSongToPlaylist(String playlistId, String songId);

  Future<PlaylistModel> addSongsToPlaylist(String playlistId, List<String> songIds);

  Future<PlaylistModel> removeSongFromPlaylist(String playlistId, String songId);

  Future<PlaylistModel> reorderPlaylistSongs(String playlistId, List<String> songIds);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final Dio dio;

  PlaylistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SongResponseModel>> getAllSongs({int page = 0, int size = 50}) async {
    try {
      final response = await dio.get(
        '/api/v1/songs',
        queryParameters: {'page': page, 'size': size},
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

  @override
  Future<List<PlaylistModel>> getMyPlaylists() async {
    try {
      Response<dynamic> response;
      try {
        response = await dio.get('/api/v1/playlists/my-playlists');
      } on DioException catch (e) {
        // Fallback to /api/v1/playlists if /my-playlists endpoint doesn't exist (404)
        if (e.response?.statusCode == 404) {
          response = await dio.get('/api/v1/playlists');
        } else {
          rethrow;
        }
      }

      final dynamic data = response.data;
      List<dynamic> items = [];

      if (data is Map<String, dynamic>) {
        final result = data['result'] ?? data['data'];
        if (result is Map<String, dynamic> && result.containsKey('content') && result['content'] is List) {
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
          .map((item) => PlaylistModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải danh sách playlist');
    }
  }

  @override
  Future<PlaylistModel> getPlaylistById(String playlistId) async {
    try {
      final response = await dio.get('/api/v1/playlists/$playlistId');
      return _parsePlaylistResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải chi tiết playlist');
    }
  }

  @override
  Future<PlaylistModel> createPlaylist(CreatePlaylistRequestModel request) async {
    try {
      final response = await dio.post(
        '/api/v1/playlists',
        data: request.toJson(),
      );
      return _parsePlaylistResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Tạo playlist thất bại');
    }
  }

  @override
  Future<PlaylistModel> updatePlaylist(String playlistId, UpdatePlaylistRequestModel request) async {
    try {
      final response = await dio.put(
        '/api/v1/playlists/$playlistId',
        data: request.toJson(),
      );
      return _parsePlaylistResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Cập nhật playlist thất bại');
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await dio.delete('/api/v1/playlists/$playlistId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Xóa playlist thất bại');
    }
  }

  @override
  Future<PlaylistModel> addSongToPlaylist(String playlistId, String songId) async {
    return await addSongsToPlaylist(playlistId, [songId]);
  }

  @override
  Future<PlaylistModel> addSongsToPlaylist(String playlistId, List<String> songIds) async {
    if (songIds.isEmpty) {
      return await getPlaylistById(playlistId);
    }
    final boundedSongIds = songIds.take(100).toList();

    try {
      final response = await dio.post(
        '/api/v1/playlists/$playlistId/songs',
        data: {
          'songIds': boundedSongIds,
          if (boundedSongIds.length == 1) 'songId': boundedSongIds.first,
        },
      );

      try {
        return _parsePlaylistResponse(response.data);
      } catch (_) {
        return await getPlaylistById(playlistId);
      }
    } on DioException catch (e) {
      if (boundedSongIds.length > 1 &&
          (e.response?.statusCode == 400 || e.response?.statusCode == 422)) {
        try {
          for (final singleId in boundedSongIds) {
            await dio.post(
              '/api/v1/playlists/$playlistId/songs',
              data: {'songId': singleId},
            );
          }
          return await getPlaylistById(playlistId);
        } catch (_) {}
      }
      throw _handleDioError(e, 'Thêm bài hát vào playlist thất bại');
    }
  }

  @override
  Future<PlaylistModel> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final response = await dio.delete('/api/v1/playlists/$playlistId/songs/$songId');

      try {
        return _parsePlaylistResponse(response.data);
      } catch (_) {
        return await getPlaylistById(playlistId);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Xóa bài hát khỏi playlist thất bại');
    }
  }

  @override
  Future<PlaylistModel> reorderPlaylistSongs(String playlistId, List<String> songIds) async {
    try {
      final response = await dio.put(
        '/api/v1/playlists/$playlistId/songs/reorder',
        data: {'songIds': songIds},
      );

      try {
        return _parsePlaylistResponse(response.data);
      } catch (_) {
        return await getPlaylistById(playlistId);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Sắp xếp bài hát thất bại');
    }
  }

  PlaylistModel _parsePlaylistResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return PlaylistModel.fromJson(responseData);
    }
    throw const FormatException('Dữ liệu playlist trả về không đúng định dạng');
  }

  Exception _handleDioError(DioException error, String fallback) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Kết nối quá hạn. Vui lòng kiểm tra server backend đang chạy.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception(
        'Không thể kết nối đến máy chủ (${dio.options.baseUrl}/api/v1/playlists).',
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
      return Exception('Bạn cần đăng nhập để thực hiện tính năng này.');
    } else if (status == 403) {
      return Exception('Bạn không có quyền thực hiện thao tác trên playlist này.');
    } else if (status == 404) {
      return Exception('Không tìm thấy playlist hoặc bài hát ($status).');
    }

    return Exception(fallback);
  }
}
