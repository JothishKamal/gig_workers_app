import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity, Failure>> login({
    required String email,
    required String password,
  });
  Future<Result<UserEntity, Failure>> signUp({
    required String email,
    required String password,
  });
  Future<Result<void, Failure>> logout();
  Stream<UserEntity?> get authStateChanges;
}
