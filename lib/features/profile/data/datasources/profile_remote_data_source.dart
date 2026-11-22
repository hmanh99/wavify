import 'package:dio/dio.dart';

import '../models/update_user_request_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getCurrentUser();
  Future<UserProfileModel> updateUser(String userId, UpdateUserRequestModel request);
  Future<void> logout(String? refreshToken);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileModel> getCurrentUser() async {
    try {
      final response = await dio.get('/api/v1/users/current-user');
      return _parseProfileResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Không thể tải thông tin người dùng');
    }
  }

  @override
  Future<UserProfileModel> updateUser(String userId, UpdateUserRequestModel request) async {
    try {
      final response = await dio.put(
        '/api/v1/users/$userId',
        data: request.toJson(),
      );
      return _parseProfileResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Cập nhật thông tin thất bại');
    }
  }

  @override
  Future<void> logout(String? refreshToken) async {
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await dio.post(
          '/api/v1/auth/logout',
          data: {
            'refreshToken': refreshToken,
            'refresh_token': refreshToken,
          },
        );
      }
    } catch (_) {
      // Best-effort logout: ignore network failures on logout
    }
  }

  UserProfileModel _parseProfileResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return UserProfileModel.fromJson(responseData);
    }
    throw const FormatException('Dữ liệu hồ sơ người dùng trả về không đúng định dạng');
  }

  Exception _handleDioError(DioException error, String fallback) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Kết nối quá hạn. Vui lòng kiểm tra server đang chạy.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception(
        'Không thể kết nối đến máy chủ (${dio.options.baseUrl}). Vui lòng kiểm tra mạng hoặc server backend.',
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
      return Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (status == 403) {
      return Exception('Bạn không có quyền thực hiện hành động này.');
    } else if (status == 404) {
      return Exception('Không tìm thấy người dùng ($status).');
    }

    return Exception(fallback);
  }
}
