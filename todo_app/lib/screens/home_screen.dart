import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_card.dart';
import '../widgets/stats_summary.dart';
import '../widgets/todo_form_sheet.dart';
import '../app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: provider.setSearchQuery,
              )
            : const Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchCtrl.clear();
                provider.setSearchQuery('');
              }
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: provider.setSort,
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: SortOption.dateCreated,
                  child: Text('Date created')),
              const PopupMenuItem(
                  value: SortOption.dueDate, child: Text('Due date')),
              const PopupMenuItem(
                  value: SortOption.priority, child: Text('Priority')),
              const PopupMenuItem(
                  value: SortOption.alphabetical,
                  child: Text('Alphabetical')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'More',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'clear') _confirmClearCompleted(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(children: [
                  Icon(Icons.cleaning_services_rounded,
                      size: 18, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  const Text('Clear completed'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats card
          const StatsSummary(),

          // Filter & Category bar
          _buildFilterBar(provider),

          // Task list
          Expanded(
            child: provider.todos.isEmpty
                ? _buildEmptyState(provider)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: provider.todos.length,
                    itemBuilder: (_, index) {
                      final todo = provider.todos[index];
                      return TodoCard(
                        key: ValueKey(todo.id),
                        todo: todo,
                        onTap: () => showTodoForm(context, todo: todo),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTodoForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 6,
      ),
    );
  }

  Widget _buildFilterBar(TodoProvider provider) {
    return Column(
      children: [
        // Status filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                count: provider.totalCount,
                selected: provider.filter == FilterOption.all,
                onTap: () => provider.setFilter(FilterOption.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Active',
                count: provider.activeCount,
                selected: provider.filter == FilterOption.active,
                onTap: () => provider.setFilter(FilterOption.active),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Done',
                count: provider.completedCount,
                selected: provider.filter == FilterOption.completed,
                onTap: () => provider.setFilter(FilterOption.completed),
              ),
            ],
          ),
        ),

        // Category scroll
        if (provider.categories.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = provider.categories[i];
                final selected = provider.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => provider.setCategory(cat),
                  selectedColor: AppTheme.primary.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primary : Colors.grey.shade600,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEmptyState(TodoProvider provider) {
    final hasFilters = provider.filter != FilterOption.all ||
        provider.searchQuery.isNotEmpty ||
        provider.selectedCategory != 'All';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.checklist_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No tasks match your filters' : 'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters.'
                : 'Tap the button below to add your first task.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context) {
    final provider = context.read<TodoProvider>();
    if (provider.completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No completed tasks to clear.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Completed'),
        content: Text(
            'Delete all ${provider.completedCount} completed tasks?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xFFF0F1FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
