import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  @override
  Future<Result<void, Failure>> call(TaskEntity task) {
    return repository.addTask(task);
  }
}
