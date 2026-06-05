// ─── Fournisseur de données global ──────────────────────────────────────────
// ChangeNotifier central de l'app. Injecté dans main.dart via ChangeNotifierProvider.
// Gère la liste des tâches, des étangs, la géolocalisation et notifie les widgets dépendants.

import 'package:flutter/material.dart';
import '../task.dart';
import '../models/pond.dart';
import '../../core/services/geo_service.dart';
import '../../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  // ==========================================
  // 👤 RÔLE & UTILISATEUR
  // ==========================================
  String? _userRole;
  String? _username;

  String? get userRole => _userRole;
  String? get username => _username;

  // Ajoute cette variable avec les autres
  int? _userId;
  int? get userId => _userId;

  /// true si le rôle permet la saisie (employé de terrain ou admin)
  bool get canEnterData =>
      _userRole == 'admin' || _userRole == 'employee' || _userRole == 'viewer';

  /// true uniquement pour les admins
  bool get isAdmin => _userRole == 'admin';

  /// Charge le profil de l'utilisateur connecté depuis /auth/me
  Future<void> loadUser() async {
    try {
      final payload = ApiService.decodeToken();
      if (payload != null) {
        _userRole = payload['role'] as String?;
        _username = payload['username'] as String?;
        _userId = payload['id'] as int?;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur décodage token : $e');
    }
  }

  /// Réinitialise les données utilisateur lors de la déconnexion
  void resetUser() {
    _userRole = null;
    _username = null;
    _tasks = [];
    notifyListeners();
  }

  // ==========================================
  // 🛰️ GÉOLOCALISATION & PERMISSIONS
  // ==========================================
  bool _isOnSite = false;
  bool _isLoadingLocation = false;

  bool get isOnSite => _isOnSite;
  bool get isLoadingLocation => _isLoadingLocation;

  Future<void> checkLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final bool result = await GeoService.checkIfOnSite();
      if (_isOnSite != result) {
        _isOnSite = result;
      }
    } catch (e) {
      debugPrint("Erreur lors de la vérification GPS dans AppProvider: $e");
      _isOnSite = false;
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void resetLocation() {
    _isOnSite = false;
    notifyListeners();
  }

  // ==========================================
  // 🐟 DONNÉES DES ÉTANGS
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

  Pond? getPondByName(String name) {
    try {
      return _ponds
          .firstWhere((pond) => pond.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // 📋 GESTION DES TÂCHES
  // ==========================================
  List<Task> _tasks = [];
  bool _isLoadingTasks = false;
  String? _tasksError;

  bool get isLoadingTasks => _isLoadingTasks;
  String? get tasksError => _tasksError;

  List<Task> get tasks => List.of(_tasks);

  Future<void> loadTasks() async {
    _isLoadingTasks = true;
    _tasksError = null;
    notifyListeners();
    try {
      final raw = await ApiService.fetchTasks(
        assignedTo: _userRole == 'employee' ? _userId?.toString() : null,
      );
      _tasks = raw
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _tasksError = e.toString();
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }

  List<Task> getTasksForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _tasks
        .where((t) =>
            !t.scheduledDate.isBefore(weekStart) &&
            t.scheduledDate.isBefore(weekEnd))
        .toList();
  }

  void updateTaskStatus(String id, TaskStatus status) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].status = status;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
