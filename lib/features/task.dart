// ─── Modèle de tâche de planning ────────────────────────────────────────────
// Utilisé par AppProvider et PlanningScreen.

/// Niveau de priorité d'une tâche.
enum TaskPriority { urgent, high, medium, low }

/// Cycle de vie d'une tâche : en attente → en cours → terminée / annulée.
enum TaskStatus { pending, inProgress, completed, cancelled }

/// Représente une tâche planifiée sur un étang.
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final TaskPriority priority;
  TaskStatus status;          // mutable : peut évoluer via AppProvider
  final String? assignedTo;  // nom de l'employé ou null si non assigné

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.priority,
    this.status = TaskStatus.pending,
    this.assignedTo,
  });

  /// Libellé français du statut, affiché dans les cartes de tâche.
  String get statusLabel => switch (status) {
        TaskStatus.pending => 'En attente',
        TaskStatus.inProgress => 'En cours',
        TaskStatus.completed => 'Terminé',
        TaskStatus.cancelled => 'Annulé',
      };

  /// Libellé français de la priorité, affiché dans le badge coloré.
  String get priorityLabel => switch (priority) {
        TaskPriority.urgent => 'Urgent',
        TaskPriority.high => 'Haute',
        TaskPriority.medium => 'Moyenne',
        TaskPriority.low => 'Basse',
      };
}
