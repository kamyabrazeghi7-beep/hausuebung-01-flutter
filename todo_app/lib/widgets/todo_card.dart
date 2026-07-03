import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../app_theme.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;

  const TodoCard({super.key, required this.todo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TodoProvider>();
    final priorityColor = AppTheme.priorityColor(todo.priority);
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(todo.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (_) => onTap(),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            SlidableAction(
              onPressed: (_) => provider.deleteTodo(todo.id),
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: todo.isCompleted
                ? const Color(0xFFF5F5F5)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: todo.isCompleted
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFFEEEEF5),
            ),
            boxShadow: todo.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 4,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: todo.isCompleted
                          ? Colors.grey.shade300
                          : priorityColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Checkbox
                  GestureDetector(
                    onTap: () => provider.toggleTodo(todo.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: todo.isCompleted
                            ? AppTheme.success
                            : Colors.transparent,
                        border: Border.all(
                          color: todo.isCompleted
                              ? AppTheme.success
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: todo.isCompleted
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: todo.isCompleted
                                ? Colors.grey
                                : const Color(0xFF1A1A2E),
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            todo.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _Chip(
                              label: todo.category,
                              icon: Icons.folder_outlined,
                              color: AppTheme.primary,
                            ),
                            if (todo.dueDate != null) ...[
                              const SizedBox(width: 6),
                              _Chip(
                                label: DateFormat('dd.MM.yy').format(todo.dueDate!),
                                icon: Icons.calendar_today_rounded,
                                color: isOverdue
                                    ? AppTheme.accent
                                    : Colors.grey.shade600,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (todo.isCompleted
                              ? Colors.grey
                              : priorityColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _priorityLabel(todo.priority),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: todo.isCompleted ? Colors.grey : priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.high:
        return 'HIGH';
      case Priority.medium:
        return 'MED';
      case Priority.low:
        return 'LOW';
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}
