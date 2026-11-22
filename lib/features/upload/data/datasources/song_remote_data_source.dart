import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../models/song_creation_request_model.dart';
import '../models/song_response_model.dart';
import '../models/song_update_request_model.dart';

abstract class SongRemoteDataSource {
  Future<SongResponseModel> uploadSong({
    required SongCreationRequestModel request,
    String? audioPath,
    Uint8List? audioBytes,
    String? audioFileName,
    String? coverPath,
    Uint8List? coverBytes,
    String? coverFileName,
    void Function(int sent, int total)? onSendProgress,
  });

  Future<SongResponseModel> updateSong(String songId, SongUpdateRequestModel request);

  Future<void> deleteSong(String songId);

  Future<List<SongResponseModel>> getMySongs();
}

class SongRemoteDataSourceImpl implements SongRemoteDataSource {
  final Dio dio;

  SongRemoteDataSourceImpl({required this.dio});

  @override
  Future<SongResponseModel> uploadSong({
    required SongCreationRequestModel request,
    String? audioPath,
    Uint8List? audioBytes,
    String? audioFileName,
    String? coverPath,
    Uint8List? coverBytes,
    String? coverFileName,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      // 1. Audio multipart part
      MultipartFile audioMultipart;
      if (audioPath != null && audioPath.isNotEmpty) {
        final filename = audioFileName ?? audioPath.split(Platform.pathSeparator).last;
        audioMultipart = await MultipartFile.fromFile(
          audioPath,
          filename: filename,
          contentType: MediaType('audio', 'mpeg'),
        );
      } else if (audioBytes != null && audioBytes.isNotEmpty) {
        audioMultipart = MultipartFile.fromBytes(
          audioBytes,
          filename: audioFileName ?? 'track.mp3',
          contentType: MediaType('audio', 'mpeg'),
        );
      } else {
        throw Exception('Vui lòng chọn tệp âm thanh để tải lên');
      }

      // 2. Cover image multipart part (optional, if no cover treat as null, no fallback)
      MultipartFile? coverMultipart;
      if (coverPath != null && coverPath.isNotEmpty) {
        final filename = coverFileName ?? coverPath.split(Platform.pathSeparator).last;
        coverMultipart = await MultipartFile.fromFile(
          coverPath,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        );
      } else if (coverBytes != null && coverBytes.isNotEmpty) {
        coverMultipart = MultipartFile.fromBytes(
          coverBytes,
          filename: coverFileName ?? 'cover.png',
          contentType: MediaType('image', 'png'),
        );
      }

      // 3. JSON metadata part
      final dataPart = MultipartFile.fromString(
        jsonEncode(request.toJson()),
        contentType: MediaType('application', 'json'),
      );

      final formMap = <String, dynamic>{
        'data': dataPart,
        'audioFile': audioMultipart,
      };
      if (coverMultipart != null) {
        formMap['coverFile'] = coverMultipart;
      }

      final formData = FormData.fromMap(formMap);

      final response = await dio.post(
        '/api/v1/songs',
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _parseSongResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Tải lên bài hát thất bại');
    }
  }

  @override
  Future<SongResponseModel> updateSong(String songId, SongUpdateRequestModel request) async {
    try {
      final response = await dio.put(
        '/api/v1/songs/$songId',
        data: request.toJson(),
      );

      return _parseSongResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Cập nhật thông tin bài hát thất bại');
    }
  }

  @override
  Future<void> deleteSong(String songId) async {
    try {
      await dio.delete('/api/v1/songs/$songId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Xóa bài hát thất bại');
    }
  }

  @override
  Future<List<SongResponseModel>> getMySongs() async {
    try {
      final response = await dio.get('/api/v1/songs/my-songs');

      final dynamic data = response.data;
      List<dynamic> items = [];

      if (data is Map<String, dynamic>) {
        if (data.containsKey('result') && data['result'] is List) {
          items = data['result'] as List<dynamic>;
        } else if (data.containsKey('data') && data['data'] is List) {
          items = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => SongResponseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải danh sách bài hát của bạn');
    }
  }

  SongResponseModel _parseSongResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return SongResponseModel.fromJson(responseData);
    }
    throw const FormatException('Dữ liệu bài hát trả về không đúng định dạng');
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
        final msgStr = message.toString();
        if (msgStr.contains('MaxUploadSizeExceededException') ||
            msgStr.contains('Maximum upload size exceeded')) {
          return Exception('Dung lượng tệp vượt quá giới hạn tối đa cho phép của máy chủ.');
        }
        return Exception(msgStr);
      }
    }

    final status = error.response?.statusCode;
    if (status == 413) {
      return Exception('Dung lượng tệp tải lên vượt quá giới hạn tối đa của máy chủ (HTTP 413).');
    } else if (status == 401) {
      return Exception('Bạn cần đăng nhập để thực hiện tính năng này.');
    } else if (status == 403) {
      return Exception('Bạn không có quyền thực hiện thao tác này.');
    } else if (status == 404) {
      return Exception('Không tìm thấy bài hát ($status).');
    }

    return Exception(fallback);
  }
}
