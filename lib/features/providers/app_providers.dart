// ─── Fournisseur de données global ──────────────────────────────────────────
// ChangeNotifier central de l'app. Injecté dans main.dart via ChangeNotifierProvider.
// Gère la liste des tâches, des étangs, la géolocalisation et notifie les widgets dépendants.

import 'package:flutter/material.dart'; // Accès au type Color et à ChangeNotifier
import '../task.dart';
import '../models/pond.dart';
import '../../core/services/geo_service.dart'; // Import de ton nouveau service géo
import '../../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  // Permissions utilisateur – à remplacer par un vrai système d'auth plus tard.
  String _userRole = 'viewer';
  String _username = '';

  bool get canEnterData => _userRole == 'admin' || _userRole == 'manager';
  bool get isAdmin => _userRole == 'admin';
  String get userRole => _userRole;
  String get username => _username;

//cette methode est appelée au lancement de l'app pour charger les infos de l'utilisateur connecté
  Future<void> loadUser() async {
    try {
      final data = await ApiService.getMe();
      if (data != null) {
        _userRole = data['user']['role'];
        _username = data['user']['username'];
        notifyListeners();
        debugPrint(
            '----------------------------🚀🚀Rôle chargé : $_userRole ------------------------------');
      }
    } catch (e) {
      debugPrint('Erreur chargement utilisateur : $e');
    }
  }

  void resetUser() {
    _userRole = 'viewer';
    _username = '';
    notifyListeners();
  }

  // ==========================================
  // 🛰️ GÉOLOCALISATION & PERMISSIONS
  // ==========================================
  bool _isOnSite = false; // état initial : pas sur le site de la ferme
  bool _isLoadingLocation =
      false; // permet d'afficher un indicateur de chargement si besoin

  // Getters publics pour accéder à l'état depuis tes composants/écrans
  bool get isOnSite => _isOnSite;
  bool get isLoadingLocation => _isLoadingLocation;

  /// Vérifie si l'utilisateur se trouve actuellement sur le site de la ferme
  /// et met à jour l'état de l'application si nécessaire.
  Future<void> checkLocation() async {
    _isLoadingLocation = true;
    notifyListeners(); // On notifie pour l'état de chargement

    try {
      // Appel asynchrone de la logique de calcul de distance et de permissions
      final bool result = await GeoService.checkIfOnSite();

      if (_isOnSite != result) {
        _isOnSite = result;
      }
    } catch (e) {
      // Sécurité : si le GPS ou les permissions plantent, on considère que l'utilisateur est hors-site
      debugPrint("Erreur lors de la vérification GPS dans AppProvider: $e");
      _isOnSite = false;
    } finally {
      _isLoadingLocation = false;
      notifyListeners(); // Mise à jour de l'interface (ex: AppBar, validation de tâche)
    }
  }

  /// Réinitialise manuellement le statut de la localisation
  void resetLocation() {
    _isOnSite = false;
    notifyListeners();
  }

  // ==========================================
  // 🐟 DONNÉES DES ÉTANGS (Ajouté pour Grâce)
  // ==========================================
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
