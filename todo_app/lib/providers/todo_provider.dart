import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../appwrite_service.dart';

enum FilterOption { all, active, completed }
enum SortOption { dateCreated, dueDate, priority, alphabetical }

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  FilterOption _filter = FilterOption.all;
  SortOption _sort = SortOption.dateCreated;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _userId;

  final AppwriteService _service = AppwriteService();

  List<Todo> get todos => _filteredAndSorted;
  FilterOption get filter => _filter;
  SortOption get sort => _sort;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _todos.map((t) => t.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;

  List<Todo> get _filteredAndSorted {
    List<Todo> result = List.from(_todos);

    if (_selectedCategory != 'All') {
      result = result.where((t) => t.category == _selectedCategory).toList();
    }

    switch (_filter) {
      case FilterOption.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case FilterOption.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case FilterOption.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_sort) {
      case SortOption.dateCreated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortOption.priority:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortOption.alphabetical:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return result;
  }

  Future<void> loadTodos() async {
    try {
      final user = await _service.getCurrentUser();
      if (user == null) return;
      _userId = user.$id;

      final docs = await _service.getTodos(_userId!);
      _todos = docs.map((d) => Todo(
        id: d['\$id'],
        title: d['title'],
        description: '',
        isCompleted: d['isDone'],
        priority: Priority.medium,
        category: 'General',
        createdAt: DateTime.now(),
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('loadTodos error: $e');
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      if (_userId == null) return;
      await _service.createTodo(todo.title, _userId!);
      await loadTodos();
    } catch (e) {
      debugPrint('addTodo error: $e');
    }
  }

  Future<void> toggleTodo(String id) async {
    try {
      final todo = _todos.firstWhere((t) => t.id == id);
      await _service.toggleTodo(id, !todo.isCompleted);
      await loadTodos();
    } catch (e) {
      debugPrint('toggleTodo error: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _service.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      debugPrint('deleteTodo error: $e');
    }
  }

  Future<void> updateTodo(Todo updated) async {
    try {
      await _service.toggleTodo(updated.id, updated.isCompleted);
      await loadTodos();
    } catch (e) {
      debugPrint('updateTodo error: $e');
    }
  }
  Future<void> clearCompleted() async {
    try {
      final completed = _todos.where((t) => t.isCompleted).toList();
      for (final todo in completed) {
        await _service.deleteTodo(todo.id);
      }
      await loadTodos();
    } catch (e) {
      debugPrint('clearCompleted error: $e');
    }
  }

  void setFilter(FilterOption filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(SortOption sort) {
    _sort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}