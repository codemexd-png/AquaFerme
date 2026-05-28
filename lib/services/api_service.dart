import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

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
    //on dit à flutter qu'il faut envoyer une requete POSTpour les données de connexion
    // à l'endpoint de connexion de l'API
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    //si la réponse de l'API est 200, cela signifie que la connexion a réussi,
    //et on retourne le token d'authentification extrait de la réponse JSON.

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return _token;
    }
    return null;//si la connexion échoue, on retourne null
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
    return null;//si la requête échoue, on retourne null
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
}
