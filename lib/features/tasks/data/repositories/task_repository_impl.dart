import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<TaskEntity>, Failure>> getTasks(String userId) async {
    try {
      final tasks = await remoteDataSource.getTasks(userId);
      return Success(tasks);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> addTask(TaskEntity task) async {
    try {
      await remoteDataSource.addTask(TaskModel.fromEntity(task));
      return const Success(null);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> updateTask(TaskEntity task) async {
    try {
      await remoteDataSource.updateTask(TaskModel.fromEntity(task));
      return const Success(null);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteTask(String taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Success(null);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
