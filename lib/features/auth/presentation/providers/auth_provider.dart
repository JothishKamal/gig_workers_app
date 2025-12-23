import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/entities/user_entity.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(firebaseAuthProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _signUpUseCase = signUpUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthInitial());

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );
    switch (result) {
      case Success(value: final user):
        state = AuthSuccess(user);
      case Error(failure: final failure):
        state = AuthError(failure.message);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AuthLoading();
    final result = await _signUpUseCase(
      SignUpParams(email: email, password: password),
    );
    switch (result) {
      case Success(value: final user):
        state = AuthSuccess(user);
      case Error(failure: final failure):
        state = AuthError(failure.message);
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    final result = await _logoutUseCase(NoParams());
    switch (result) {
      case Success():
        state = const AuthInitial();
      case Error(failure: final failure):
        state = AuthError(failure.message);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      loginUseCase: ref.read(loginUseCaseProvider),
      signUpUseCase: ref.read(signUpUseCaseProvider),
      logoutUseCase: ref.read(logoutUseCaseProvider),
    );
  },
);
