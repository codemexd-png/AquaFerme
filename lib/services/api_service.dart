import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:flutter/material.dart';

//ce srvice permet de gérer les appels API
class ApiService {
  //_token est une variable privée qui stocke le token d'authentification de l'utilisateur après la connexion.
  static String? _token;

//setter pour le token d'authentification
  static void setToken(String token) {
    _token = token;
  }

//le login est une méthode statique qui prend en paramètre le nom d'utilisateur et le mot de passe,
//effectue une requête POST à l'endpoint de connexion de l'API,
//et retourne le token d'authentification si la connexion est réussie.
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return _token;
      }
      return null;
    } catch (e) {
      return null; // timeout ou erreur réseau → retourne null proprement
    }
  }

// getMe permet de récupérer les informations de l'utilisateur connecté en effectuant
//une requête GET à l'endpoint /auth/me de l'API.
  static Future<Map<String, dynamic>?> getMe() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null; //si la requête échoue, on retourne null
  }

  // Récupérer tous les étangs
  static Future<List<dynamic>> getPonds({String? category}) async {
    final url = category == null
        ? '${AppConfig.baseUrl}/ponds'
        : '${AppConfig.baseUrl}/ponds?category=$category';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erreur chargement étangs');
  }

  // Récupérer tous les utilisateurs (pour l'assignation des tâches)
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token'
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['users'];
    }
    return [];
  }

  // Récupérer un étang par son ID
  static Future<Map<String, dynamic>> getPondById(String id) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/ponds/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erreur chargement détail étang');
  }

  // Récupérer toutes les tâches (utilisé par AppProvider)
  static Future<List<dynamic>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tasks'];
    }
    return [];
  }

  static Map<String, dynamic>? decodeToken() {
    if (_token == null) return null;
    try {
      final parts = _token!.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Erreur décodage JWT : $e');
      return null;
    }
  }

// Récupérer les statistiques d'un étang par son ID
  static Future<Map<String, dynamic>> getPondStats(String id) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/ponds/$id/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erreur chargement stats étang');
  }

// Récupérer le stock de nourriture
  static Future<List<dynamic>> getFeedStock() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/feed-stock'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erreur chargement stock');
  }

// Mettre à jour le stock de nourriture
  static Future<void> updateFeedStock({
    required String id,
    required double quantityKg,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/feed-stock/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'quantity_kg': quantityKg}),
    );
    if (response.statusCode != 200) throw Exception('Erreur mise à jour stock');
  }

// Saisir la nourriture du jour pour un étang
  static Future<void> updateDailyFeed({
    required String pondId,
    required double foodGivenKg,
    required double foodPlannedKg,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/ponds/$pondId/feed'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'food_given_kg': foodGivenKg,
        'food_planned_kg': foodPlannedKg,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur saisie nourriture');
    }
  }

  // Créer une nouvelle tâche de planning
  static Future<void> createTask({
    required String title,
    String? pondId,
    required String taskDate,
    required String priority,
    String? assignedTo,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'title': title,
        'pond_id': pondId != null ? int.tryParse(pondId) : null,
        'task_date': taskDate,
        'priority': priority,
        'assigned_to': assignedTo != null ? int.tryParse(assignedTo) : null,
        'description': description,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur création tâche');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchWaterQuality() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/water-quality'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['measurements'] as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Erreur chargement qualité eau');
  }

  static Future<void> saveWaterQuality({
    required String pondId,
    required double temperatureC,
    required double oxygenMgL,
    required String waterColor,
    String? notes,
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/water-quality'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'pond_id': int.tryParse(pondId),
        'measurement_date': today,
        'temperature_c': temperatureC,
        'oxygen_level_mg_l': oxygenMgL,
        'water_color': waterColor,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur enregistrement mesure');
    }
  }

  // Récupérer les stats globales du dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/ponds/dashboard-stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur chargement dashboard');
  }

  static Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['notifications'] as List<dynamic>;
    }
    throw Exception('Erreur chargement notifications');
  }

  static Future<void> markNotificationRead(String id) async {
    await http.patch(
      Uri.parse('${AppConfig.baseUrl}/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $_token'},
    );
  }

  static Future<void> markAllNotificationsRead() async {
    await http.patch(
      Uri.parse('${AppConfig.baseUrl}/notifications/read-all'),
      headers: {'Authorization': 'Bearer $_token'},
    );
  }
}
