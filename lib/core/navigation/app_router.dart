import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/screens/splash_screen.dart';
// Les imports pour Login et Home seront ajoutés dès qu'on créera ces fichiers
import '../../features/screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashView(),
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
    
  ],
);
