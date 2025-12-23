import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase implements UseCase<void, String> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Result<void, Failure>> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}
