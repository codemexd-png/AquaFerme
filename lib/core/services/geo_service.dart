import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

// Ce service gère la géolocalisation pour vérifier si l'utilisateur est sur le site de la ferme.
class GeoService {
// Coordonnées de la ferme

  static const double _farmLat = 6.818500;
  static const double _farmLng = -3.426028;
  static const double _maxDistance = 500; // mètres

  static Future<bool> checkIfOnSite() async { 
    bool serviceEnabled;
    LocationPermission permission;
    // En mode debug, on considère que l'utilisateur est toujours sur le site pour faciliter les tests.
    if (kDebugMode) return true;
    // 1. Vérifier si le service de localisation du téléphone est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation ne sont pas activés, impossible de continuer
      return false;
    }

    // 2. Vérifier le statut actuel des permissions de l'application
    permission = await Geolocator.checkPermission();

    // Si la permission est totalement refusée (bloquée dans les paramètres)
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // 3. Demander la permission si elle n'a pas encore été accordée
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // L'utilisateur a cliqué sur "Refuser" au moment du pop-up
        return false;
      }
    }

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      debugPrint('📍 Last known position: $position');

      if (position == null) {
        debugPrint('📍 Aucun cache, tentative getCurrentPosition...');
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.lowest,
          timeLimit: const Duration(seconds: 20),
        );
        debugPrint('📍 Current position: $position');
      }

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _farmLat,
        _farmLng,
      );

      return distanceInMeters <= _maxDistance;
    } catch (e) {
      debugPrint('❌ GeoService erreur : $e');
      return false;
    }
  }
}
