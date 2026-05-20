// ─── Configuration du routeur GoRouter ───────────────────────────────────────
// Toutes les routes de l'application sont déclarées ici.
// Route initiale : '/' (SplashView) → redirige vers '/planning'.

import 'package:go_router/go_router.dart';
import '../../features/screens/splash_screen.dart';
import '../../features/screens/planning_screen.dart';
import '../../features/screens/add_operation_screen.dart';
import '../../features/screens/water_quality_screen.dart';
import '../../features/screens/add_task_screen.dart';
import '../../features/screens/mortality_screen.dart';
import '../../features/screens/transfer_screen.dart';
import '../../features/screens/pond_detail_screen.dart';
import '../../features/screens/pond_list_screen.dart';
import '../../features/screens/occupancy_screen.dart';
import '../../features/screens/dam_screen.dart';
import '../../features/screens/settings_Screen.dart';
// Les imports pour Login et Home seront ajoutés dès qu'on créera ces fichiers
import '../../features/screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/planning',
      builder: (context, state) => const PlanningPage(),
    ),
    GoRoute(
      path: '/add-operation',
      builder: (context, state) => const AddOperationScreen(),
    ),
    GoRoute(
      path: '/water-quality',
      builder: (context, state) => const WaterQualityScreen(),
    ),
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: '/mortality',
      builder: (context, state) => const MortalityScreen(),
    ),
    GoRoute(
      path: '/transfer',
      builder: (context, state) => const TransferScreen(),
    ),
    /*  les routes pour le login et la home  
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    */
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
   GoRoute(
  path: '/pond/:id',
  builder: (context, state) {
    final pondId = state.pathParameters['id']!;
    final extra = state.extra as Map<String, dynamic>?;
    return PondDetailScreen(pondId: pondId, pondData: extra);
  },
),
    GoRoute(
      path: '/pond-list',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'] ?? 'Tous';
        return PondListScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/occupancy',
      builder: (context, state) => const OccupancyScreen(),
    ),
    GoRoute(
      path: '/dam',
      builder: (context, state) => const DamScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
