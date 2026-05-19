// ─── Fournisseur de données global ──────────────────────────────────────────
// ChangeNotifier central de l'app. Injecté dans main.dart via ChangeNotifierProvider.
// Gère la liste des tâches et notifie les widgets dépendants à chaque modification.

import 'package:flutter/foundation.dart';
import '../task.dart';

class AppProvider extends ChangeNotifier {
  // Permissions utilisateur – à remplacer par un vrai système d'auth plus tard.
  final bool canEnterData = true;
  final bool isAdmin = false;

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Pêche de contrôle A5',
      description: 'Vérifier la densité et le poids moyen des poissons',
      scheduledDate: DateTime(2026, 5, 19),
      priority: TaskPriority.high,
      assignedTo: 'Konan',
    ),
    Task(
      id: '2',
      title: 'Mesure qualité eau – Étang B',
      description: 'Relevé O₂, température et couleur',
      scheduledDate: DateTime(2026, 5, 20),
      priority: TaskPriority.medium,
      assignedTo: 'Yao',
    ),
    Task(
      id: '3',
      title: 'Nettoyage filets étangs C1',
      description: 'Remplacer les filets endommagés',
      scheduledDate: DateTime(2026, 5, 21),
      priority: TaskPriority.low,
      assignedTo: 'Konah',
    ),
  ];

  /// Retourne une copie mutable de la liste (pour que le tri externe n'affecte pas _tasks)
  List<Task> get tasks => List.of(_tasks);

  /// Retourne les tâches dont la date est dans la semaine commençant à [weekStart].
  List<Task> getTasksForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _tasks
        .where((t) =>
            !t.scheduledDate.isBefore(weekStart) &&
            t.scheduledDate.isBefore(weekEnd))
        .toList();
  }

  /// Met à jour le statut d'une tâche et notifie les listeners.
  void updateTaskStatus(String id, TaskStatus status) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].status = status;
      notifyListeners();
    }
  }

  /// Supprime une tâche par son id et notifie les listeners.
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
