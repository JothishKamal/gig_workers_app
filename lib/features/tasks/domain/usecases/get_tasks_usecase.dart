import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<List<TaskEntity>, String> {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Result<List<TaskEntity>, Failure>> call(String userId) {
    return repository.getTasks(userId);
  }
}
