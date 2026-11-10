import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../domain/entities/focus_task.dart';
import '../cubit/task_cubit.dart';
import '../widgets/delete_task_dialog.dart';
import '../widgets/task_tile.dart';

/// Form untuk Create (task == null) dan Update (task != null).
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.task});

  final FocusTask? task;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late int _estimate;
  late TaskPriority _priority;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _estimate = task?.estimatedPomodoros ?? 1;
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    // Validasi di UI terlebih dahulu ...
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final cubit = context.read<TaskCubit>();
    // ... lalu repository memvalidasi ulang sebelum menyimpan ke database.
    final error = _isEdit
        ? await cubit.updateTask(
            widget.task!.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              estimatedPomodoros: _estimate,
              priority: _priority,
            ),
          )
        : await cubit.addTask(
            title: _titleController.text,
            description: _descriptionController.text,
            estimatedPomodoros: _estimate,
            priority: _priority,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).error(error))),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final task = widget.task!;
    final cubit = context.read<TaskCubit>();
    final navigator = Navigator.of(context);
    if (!await confirmDeleteTask(context, task)) return;
    final error = await cubit.deleteTask(task);
    if (error == null) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? s.editTask : s.newTask),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: s.deleteTaskTooltip,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: ResponsiveCenter(
            maxWidth: 560,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Label(s.titleLabel),
                  TextFormField(
                    key: const Key('task_title'),
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: Validators.taskTitleMax,
                    decoration: InputDecoration(hintText: s.titleHint),
                    validator: (v) => s.errorOrNull(Validators.taskTitle(v)),
                  ),
                  const SizedBox(height: 8),
                  _Label(s.descriptionLabel),
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 3,
                    maxLength: Validators.taskDescriptionMax,
                    decoration: InputDecoration(hintText: s.descriptionHint),
                    validator: (v) =>
                        s.errorOrNull(Validators.taskDescription(v)),
                  ),
                  const SizedBox(height: 8),
                  _Label(s.estimateLabel),
                  FormField<int>(
                    initialValue: _estimate,
                    validator: (v) =>
                        s.errorOrNull(Validators.estimatedPomodoros(v)),
                    builder: (field) => _EstimateStepper(
                      value: _estimate,
                      errorText: field.errorText,
                      onChanged: (value) {
                        setState(() => _estimate = value);
                        field.didChange(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Label(s.priorityLabel),
                  SegmentedButton<TaskPriority>(
                    showSelectedIcon: false,
                    segments: [
                      for (final priority in TaskPriority.values)
                        ButtonSegment(
                          value: priority,
                          label: Text(priorityLabel(s, priority)),
                          icon: Icon(
                            Icons.flag_rounded,
                            color: priorityColor(priority),
                            size: 18,
                          ),
                        ),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (value) =>
                        setState(() => _priority = value.first),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    key: const Key('task_save'),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(_isEdit ? s.saveChanges : s.addTaskButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EstimateStepper extends StatelessWidget {
  const _EstimateStepper({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText == null ? AppColors.border : Colors.redAccent,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: s.decrease,
                onPressed: value > Validators.pomodoroMin
                    ? () => onChanged(value - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Text(
                  s.estimateValue(value, value * 25),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: s.increase,
                onPressed: value < Validators.pomodoroMax
                    ? () => onChanged(value + 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
