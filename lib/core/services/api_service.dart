// ─── Service HTTP centralisé ──────────────────────────────────────────────────
// Point d'entrée unique pour toutes les requêtes vers le backend REST.
// ⚠️  Adapter _baseUrl selon l'environnement :
//     - Émulateur Android  → 'http://10.0.2.2:3000'
//     - Simulateur iOS     → 'http://localhost:3000'
//     - Appareil physique  → 'http://<IP_DU_SERVEUR>:3000'

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/task.dart'; //

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000'; //on doit changer _baseUrl selon ton environnement (émulateur Android = 10.0.2.2, appareil physique = l'IP réelle du serveur).

  // ── Token JWT ─────────────────────────────────────────────────────────────
  static String? _token;
  static String? get token => _token;

  static Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Authentification ──────────────────────────────────────────────────────

  /// POST /auth/login → retourne les infos utilisateur et stocke le token JWT
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      _token = data['token'] as String?;
      return data;
    }
    throw Exception('Identifiants invalides (${response.statusCode})');
  }

  /// Efface le token (déconnexion)
  static void logout() => _token = null;

  // ── Tâches ────────────────────────────────────────────────────────────────

  /// GET /tasks → liste de toutes les tâches
  static Future<List<Task>> fetchTasks() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/tasks'), headers: _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur serveur (${response.statusCode}) : /tasks');
  }

  // ── Qualité de l'eau ──────────────────────────────────────────────────────

  /// GET /water-quality → liste des mesures
  static Future<List<Map<String, dynamic>>> fetchWaterQuality() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/water-quality'), headers: _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(
        'Erreur serveur (${response.statusCode}) : /water-quality');
  }

  /// POST /water-quality → enregistre une nouvelle mesure
  static Future<void> saveWaterQuality({
    required String pondId,
    required double temperatureC,
    required double oxygenMgL,
    required String waterColor,
    String? notes,
  }) async {
    final body = json.encode({
      'pond_id': pondId,
      'temperature_c': temperatureC,
      'oxygen_mg_l': oxygenMgL,
      'water_color': waterColor,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });

    final response = await http
        .post(
          Uri.parse('$_baseUrl/water-quality'),
          headers: _authHeaders,
          body: body,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur serveur (${response.statusCode}) : POST /water-quality');
    }
  }
}