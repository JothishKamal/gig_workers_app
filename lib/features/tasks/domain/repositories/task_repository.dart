import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Result<List<TaskEntity>, Failure>> getTasks(String userId);
  Future<Result<void, Failure>> addTask(TaskEntity task);
  Future<Result<void, Failure>> updateTask(TaskEntity task);
  Future<Result<void, Failure>> deleteTask(String taskId);
}
