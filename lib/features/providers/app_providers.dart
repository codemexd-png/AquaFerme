// ─── Fournisseur de données global ──────────────────────────────────────────
// ChangeNotifier central de l'app. Injecté dans main.dart via ChangeNotifierProvider.
// Gère la liste des tâches, des étangs et notifie les widgets dépendants.

import 'package:flutter/material.dart'; // Remplacé pour avoir accès au type Color
import '../task.dart';

import '../models/pond.dart';

class AppProvider extends ChangeNotifier {
  // Permissions utilisateur – à remplacer par un vrai système d'auth plus tard.
  final bool canEnterData = true;
  final bool isAdmin = false;

  // ==========================================
  // 🐟 DONNÉES DES ÉTANGS (Ajouté pour Grâce)
  // ==========================================
  // Ici, on crée une liste d'étangs de test mockés qui matchent les variables de son écran
  final List<Pond> _ponds = [
    Pond(
      name: 'Étang A1',
      category: 'Élevage',
      surface: 120,
      fish: 250,
      weight: 45.2,
      percent: 83.3,
    ),
    Pond(
      name: 'Étang B3',
      category: 'Alevinage',
      surface: 80,
      fish: 180,
      weight: 12.5,
      percent: 90.0,
    ),
    Pond(
      name: 'Étang C2',
      category: 'Reproduction',
      surface: 150,
      fish: 110,
      weight: 120.0,
      percent: 29.3,
    ),
  ];

  List<Pond> get ponds => _ponds;

  /// 🔍 Cherche un étang par son nom (utilisé par GoRouter via /pond/:id)
  Pond? getPondByName(String name) {
    try {
      return _ponds
          .firstWhere((pond) => pond.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null; // Retourne null si l'étang n'existe pas
    }
  }

  // ==========================================
  // 📋 GESTION DES TÂCHES (Ton code initial)
  // ==========================================
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
