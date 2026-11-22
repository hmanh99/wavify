import 'package:dio/dio.dart';

import '../models/auth_tokens_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login(LoginRequestModel request);
  Future<AuthTokensModel> register(RegisterRequestModel request);
  Future<AuthTokensModel> refresh(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthTokensModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Đăng nhập thất bại');
    }
  }

  @override
  Future<AuthTokensModel> register(RegisterRequestModel request) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Đăng ký tài khoản thất bại');
    }
  }

  @override
  Future<AuthTokensModel> refresh(String refreshToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Làm mới token thất bại');
    }
  }

  AuthTokensModel _parseAuthResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return AuthTokensModel.fromJson(responseData);
    }
    throw const FormatException('Dữ liệu trả về từ server không đúng định dạng');
  }

  Exception _handleDioError(DioException error, String fallbackMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Kết nối máy chủ quá hạn (Timeout). Vui lòng kiểm tra server đang chạy.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception(
        'Không thể kết nối đến máy chủ (${dio.options.baseUrl}). Vui lòng kiểm tra server backend.',
      );
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['msg'];
      if (message != null && message.toString().isNotEmpty) {
        return Exception(message.toString());
      }
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 400) {
      return Exception('Dữ liệu yêu cầu không hợp lệ. Vui lòng kiểm tra lại thông tin.');
    } else if (statusCode == 401) {
      return Exception('Email hoặc mật khẩu không chính xác.');
    } else if (statusCode == 403) {
      return Exception('Bạn không có quyền thực hiện hành động này.');
    } else if (statusCode == 404) {
      return Exception('Không tìm thấy API xác thực ($statusCode).');
    } else if (statusCode == 409) {
      return Exception('Tài khoản hoặc email đã tồn tại trên hệ thống.');
    } else if (statusCode != null && statusCode >= 500) {
      return Exception('Lỗi hệ thống máy chủ ($statusCode). Vui lòng thử lại sau.');
    }

    return Exception(fallbackMessage);
  }
}
