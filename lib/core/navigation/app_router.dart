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
// Les imports pour Login et Home seront ajoutés dès qu'on créera ces fichiers

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    */
  ],
);
