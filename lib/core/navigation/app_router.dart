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
import '../../features/screens/login_screen.dart';
import '../../features/screens/home_screen.dart';
import '../../widgets/app_navigation.dart'; // à ajouter
import '../../features/screens/feed_stock_screen.dart';

final GoRouter appRouter = GoRouter(
  //Permet de démarrer l'application sur le SplashView, qui redirigera ensuite vers le LoginScreen après une courte pause.
  initialLocation: '/',
  routes: [
    // ─── Hors shell (pas de bottom nav) ──────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/pond/:id',
      builder: (context, state) {
        final pondId = state.pathParameters['id']!;
        return PondDetailScreen(pondId: pondId);
      },
    ),
    GoRoute(
      path: '/add-operation',
      builder: (context, state) => const AddOperationScreen(),
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
    GoRoute(
      path: '/dam',
      builder: (context, state) => const DamScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
GoRoute(
  path: '/feed-stock',
  builder: (context, state) => const FeedStockScreen(),
),
    // ─── Dans le shell (avec bottom nav) ─────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppNavigation(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/pond-list',
          builder: (context, state) {
            final category = state.uri.queryParameters['category'] ?? 'Tous';
            return PondListScreen(initialCategory: category);
          },
        ),
        GoRoute(
          path: '/water-quality',
          builder: (context, state) => const WaterQualityScreen(),
        ),
        GoRoute(
          path: '/planning',
          builder: (context, state) => const PlanningPage(),
        ),
        GoRoute(
          path: '/occupancy',
          builder: (context, state) => const OccupancyScreen(),
        ),
      ],
    ),
  ],
);
