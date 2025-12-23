import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../../../core/utils/retry_util.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.read(firestoreProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(taskRemoteDataSourceProvider));
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.read(taskRepositoryProvider));
});

final addTaskUseCaseProvider = Provider<AddTaskUseCase>((ref) {
  return AddTaskUseCase(ref.read(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.read(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.read(taskRepositoryProvider));
});

class TaskFilterState {
  final TaskPriority? priority;
  final bool? isCompleted;
  final String searchQuery;

  const TaskFilterState({
    this.priority,
    this.isCompleted,
    this.searchQuery = '',
  });

  TaskFilterState copyWith({
    TaskPriority? Function()? priority,
    bool? Function()? isCompleted,
    String? searchQuery,
  }) {
    return TaskFilterState(
      priority: priority != null ? priority() : this.priority,
      isCompleted: isCompleted != null ? isCompleted() : this.isCompleted,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final taskFilterProvider = StateProvider<TaskFilterState>(
  (ref) => const TaskFilterState(),
);

final taskListProvider =
    StateNotifierProvider<TaskListController, AsyncValue<List<TaskEntity>>>((
      ref,
    ) {
      final user = ref.watch(authStateChangesProvider).value;
      return TaskListController(ref, userId: user?.uid);
    });

final filteredTaskListProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasksAsync.whenData((tasks) {
    return tasks.where((task) {
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }
      if (filter.isCompleted != null &&
          task.isCompleted != filter.isCompleted) {
        return false;
      }
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) {
          return false;
        }
      }
      return true;
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  });
});

class TaskListController extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final Ref ref;
  final String? userId;

  TaskListController(this.ref, {this.userId})
    : super(const AsyncValue.loading()) {
    if (userId != null) {
      loadTasks();
    }
  }

  Future<void> loadTasks() async {
    if (userId == null) return;
    state = const AsyncValue.loading();
    try {
      final result = await retryWithBackoff(
        () => ref.read(getTasksUseCaseProvider)(userId!),
      );
      switch (result) {
        case Success(value: final tasks):
          state = AsyncValue.data(tasks);
        case Error(failure: final failure):
          state = AsyncValue.error(failure.message, StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> addTask(TaskEntity task) async {
    final previousState = state;
    if (previousState.hasValue) {
      final currentList = previousState.value!;
      state = AsyncValue.data([...currentList, task]);
    }

    try {
      final result = await retryWithBackoff(
        () => ref.read(addTaskUseCaseProvider)(task),
      );

      if (result is Error) {
        state = previousState;
      } else {}
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    final previousState = state;
    if (previousState.hasValue) {
      final currentList = previousState.value!;
      final index = currentList.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final updatedList = List<TaskEntity>.from(currentList);
        updatedList[index] = task;
        state = AsyncValue.data(updatedList);
      }
    }

    try {
      final result = await retryWithBackoff(
        () => ref.read(updateTaskUseCaseProvider)(task),
      );
      if (result is Error) {
        state = previousState;
      }
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final previousState = state;
    if (previousState.hasValue) {
      final currentList = previousState.value!;
      final updatedList = currentList.where((t) => t.id != taskId).toList();
      state = AsyncValue.data(updatedList);
    }

    try {
      final result = await retryWithBackoff(
        () => ref.read(deleteTaskUseCaseProvider)(taskId),
      );
      if (result is Error) {
        state = previousState;
      }
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> toggleComplete(TaskEntity task) async {
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: !task.isCompleted,
      userId: task.userId,
    );
    await updateTask(updated);
  }
}
