import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

class AddEditTaskPage extends ConsumerStatefulWidget {
  final TaskEntity? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  ConsumerState<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends ConsumerState<AddEditTaskPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _selectedPriority = widget.task!.priority;
    } else {
      _selectedDate = DateTime.now();
      _selectedPriority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final desc = _descController.text.trim();

      final controller = ref.read(taskListProvider.notifier);
      final userId = controller.userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in found')),
        );
        return;
      }

      if (widget.task != null) {
        final updatedTask = TaskEntity(
          id: widget.task!.id,
          title: title,
          description: desc,
          dueDate: _selectedDate,
          priority: _selectedPriority,
          isCompleted: widget.task!.isCompleted,
          userId: userId,
        );
        controller.updateTask(updatedTask);
      } else {
        final newTask = TaskEntity(
          id: const Uuid().v4(),
          title: title,
          description: desc,
          dueDate: _selectedDate,
          priority: _selectedPriority,
          isCompleted: false,
          userId: userId,
        );
        controller.addTask(newTask);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What needs to be done?',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add details...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text('Due Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM d, y').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Priority', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: const [
                  ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                  ButtonSegment(
                    value: TaskPriority.medium,
                    label: Text('Medium'),
                  ),
                  ButtonSegment(value: TaskPriority.high, label: Text('High')),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (Set<TaskPriority> newSelection) {
                  setState(() {
                    _selectedPriority = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save Changes' : 'Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
