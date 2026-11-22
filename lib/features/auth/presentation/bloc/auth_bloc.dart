import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final isAuth = await checkAuthStatusUseCase();
      if (isAuth) {
        final user = await authRepository.getCurrentUser();
        // Tokens are in secure storage
        emit(AuthAuthenticated(
          tokens: AuthTokens.empty,
          user: user,
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim();
    final password = event.password;

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Vui lòng nhập đầy đủ email và mật khẩu'));
      return;
    }

    emit(const AuthLoading());
    try {
      final tokens = await loginUseCase(email: email, password: password);
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(tokens: tokens, user: user));
    } catch (e) {
      emit(AuthFailure(_cleanErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    final fullName = event.fullName.trim();
    final email = event.email.trim();
    final password = event.password;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Vui lòng điền đầy đủ các thông tin'));
      return;
    }

    if (password.length < 8) {
      emit(const AuthFailure('Mật khẩu phải có tối thiểu 8 ký tự'));
      return;
    }

    emit(const AuthLoading());
    try {
      final tokens = await registerUseCase(
        fullName: fullName,
        email: email,
        password: password,
      );
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(tokens: tokens, user: user));
    } catch (e) {
      emit(AuthFailure(_cleanErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  void _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated(
      message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    ));
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }
}
