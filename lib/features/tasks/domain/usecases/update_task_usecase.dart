import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Result<void, Failure>> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
