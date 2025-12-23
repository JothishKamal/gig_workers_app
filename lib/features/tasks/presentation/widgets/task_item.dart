import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';

class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getPriorityColor(BuildContext context, TaskPriority priority) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case TaskPriority.high:
        return isDark
            ? Colors.red.withAlpha((0.2 * 255).toInt())
            : Colors.red.shade100;
      case TaskPriority.medium:
        return isDark
            ? Colors.orange.withAlpha((0.2 * 255).toInt())
            : Colors.orange.shade100;
      case TaskPriority.low:
        return isDark
            ? Colors.green.withAlpha((0.2 * 255).toInt())
            : Colors.green.shade100;
    }
  }

  Color _getPriorityTextColor(BuildContext context, TaskPriority priority) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case TaskPriority.high:
        return isDark ? Colors.red.shade200 : Colors.red.shade900;
      case TaskPriority.medium:
        return isDark ? Colors.orange.shade200 : Colors.orange.shade900;
      case TaskPriority.low:
        return isDark ? Colors.green.shade200 : Colors.green.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        }
        return true;
      },
      background: Container(
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.check, color: Colors.white),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.transparent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: colorScheme.primary,
            checkColor: colorScheme.onPrimary,
            shape: const CircleBorder(),
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? colorScheme.outline
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.dueDate),
                    style: TextStyle(color: colorScheme.outline, fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(context, task.priority),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: TextStyle(
                        color: _getPriorityTextColor(context, task.priority),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
