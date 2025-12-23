import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme_provider.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTaskListProvider);
    final filterState = ref.watch(taskFilterProvider);
    final user = ref.watch(authStateChangesProvider).value;

    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          user != null ? user.email.split('@')[0] : 'User',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    icon:
                        Icon(
                              ref.watch(themeProvider) == ThemeMode.light
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                            )
                            .animate(
                              target:
                                  ref.watch(themeProvider) == ThemeMode.light
                                  ? 0
                                  : 0.5,
                            )
                            .rotate(begin: 0, end: 1),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                    icon: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                onChanged: (value) {
                  ref
                      .read(taskFilterProvider.notifier)
                      .update((state) => state.copyWith(searchQuery: value));
                },
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected:
                        filterState.priority == null &&
                        filterState.isCompleted == null,
                    onSelected: () {
                      ref.read(taskFilterProvider.notifier).state =
                          const TaskFilterState();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Incomplete',
                    isSelected: filterState.isCompleted == false,
                    onSelected: () {
                      ref
                          .read(taskFilterProvider.notifier)
                          .update((s) => s.copyWith(isCompleted: () => false));
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Completed',
                    isSelected: filterState.isCompleted == true,
                    onSelected: () {
                      ref
                          .read(taskFilterProvider.notifier)
                          .update((s) => s.copyWith(isCompleted: () => true));
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'High Priority',
                    isSelected: filterState.priority == TaskPriority.high,
                    onSelected: () {
                      ref
                          .read(taskFilterProvider.notifier)
                          .update(
                            (s) =>
                                s.copyWith(priority: () => TaskPriority.high),
                          );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: tasks.when(
                data: (taskList) {
                  if (taskList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      final task = taskList[index];
                      return TaskItem(
                            task: task,
                            onTap: () async {
                              context.push('/edit-task', extra: task);
                            },
                            onToggle: () {
                              ref
                                  .read(taskListProvider.notifier)
                                  .toggleComplete(task);
                            },
                            onDelete: () {
                              ref
                                  .read(taskListProvider.notifier)
                                  .deleteTask(task.id);
                            },
                          )
                          .animate(delay: (100 * index).ms)
                          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                          .slideX(
                            begin: 0.2,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load tasks',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final _ = ref.refresh(taskListProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: colorScheme.surfaceContainer,
      selectedColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : colorScheme.outline.withAlpha((0.2 * 255).toInt()),
        ),
      ),
      showCheckmark: false,
    );
  }
}
