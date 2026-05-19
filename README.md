# 🐟 AquaProject — Application de Gestion Interne (Ferme Piscicole)

Bienvenue sur le dépôt officiel de l'application mobile d'**AquaProject**. [cite_start]Ce projet est une application de gestion interne destinée à une ferme piscicole en Côte d'Ivoire[cite: 2].

[cite_start]Pour cette **Semaine 1 (du 19 au 24 mai 2026)**, l'objectif exclusif est de réaliser le **front-end mobile complet en version statique** (UI avec données mockées), sans backend ni dashboard pour le moment[cite: 1, 2, 3, 4]. [cite_start]La livraison finale globale est fixée au **5 juin 2026**[cite: 4].

---

## 🚀 Comment démarrer le projet ?

Pour lancer l'application localement sur votre émulateur ou appareil physique sans aucune erreur, suivez ces étapes :

1. **Récupérer les dépendances :**
   Ouvrez votre terminal dans le dossier `aquaferme` et exécutez la commande suivante pour installer `go_router`, `provider`, `geolocator`, et les autres outils nécessaires :

   flutter pub get

2. **Architecture du projet :**
---

## 📁 Structure du Projet & Attribution des Rôles

Voici l'organisation des fichiers et qui est responsable de chaque partie pour le développement :

lib/
├── main.dart                          # 🛠️ Ibrahim (Point d'entrée & initialisation)
│
├── model/                             # 📦 Modèles de données (Géré principalement par Lyly)
│   ├── pond.dart                      # Lyly (Modèle Étang + historique)
│   ├── task.dart                      # Lyly (Modèle Tâches)
│   ├── water_quality.dart             # Lyly (Modèle Qualité de l'eau)
│   └── fish_operations.dart           # À nettoyer (vide)
│
├── providers/                         # 🧠 Gestion de l'état global
│   └── app_providers.dart             # 🤝 Ibrahim, Grâce & Lyly (Centralisation des données)
│
├── screens/                           # 🖥️ Les Écrans de l'application
│   ├── login_screen.dart              # 🧑‍💻 Ibrahim (Connexion & Mode Admin)
│   ├── settings_screen.dart           # 🧑‍💻 Ibrahim (Profil & Statut de géolocalisation)
│   │
│   ├── home_screen.dart               # 👩‍💻 Grâce (Dashboard & Onglets principaux)
│   ├── pond_list_screen.dart          # 👩‍💻 Grâce (Liste filtrable des étangs A/B/C/D)
│   ├── pond_detail_screen.dart        # 👩‍💻 Grâce (Détail de l'étang & Jauge d'occupation)
│   ├── occupancy_screen.dart          # 👩‍💻 Grâce (Grille des densités globales)
│   ├── dam_screen.dart                # 👩‍💻 Grâce (Suivi du Barrage principal)
│   │
│   ├── add_operation_screen.dart      # 👩‍💻 Lyly (Formulaire : Pêche de contrôle)
│   ├── mortality_screen.dart          # 👩‍💻 Lyly (Formulaire : Déclaration de mortalité)
│   ├── transfer_screen.dart           # 👩‍💻 Lyly (Formulaire : Transfert de poissons)
│   ├── water_quality_screen.dart      # 👩‍💻 Lyly (Saisie et liste de la qualité de l'eau)
│   ├── planning_screen.dart           # 👩‍💻 Lyly (Vue hebdomadaire du calendrier de tâches)
│   └── add_task_screen.dart           # 👩‍💻 Lyly (Formulaire de création de tâche)
│
├── services/                          # 🛰️ Services techniques
│   └── geolocation_services.dart      # 🧑‍💻 Ibrahim (Calcul GPS Haversine - rayon 500m)
│
└── widgets/                           # 🧩 Composants UI réutilisables (Création partagée)
    ├── stat_card.dart                 # 👩‍💻 Grâce (Tuiles KPIs du Dashboard)
    ├── pond_card.dart                 # 👩‍💻 Grâce (Composant visuel des étangs)
    └── occupation_gauge.dart          # 👩‍💻 Grâce (Composant Jauge circulaire personnalisé)
