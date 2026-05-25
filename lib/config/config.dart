
/**
 * vu que pour les tests on utilise un vrai telephone alors 
 * il faut lancer d'abord adb reverse tcp:3000 tcp:3000 qui fait le lien entre le port 3000 de l'ordinateur et le port 3000 du téléphone.
 * Ensuite on peut utiliser http://localhost:3000 pour accéder à l'API depuis le téléphone.
 */
class AppConfig {
  static const String baseUrl = 'http://localhost:3000';
}