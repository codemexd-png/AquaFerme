import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // ─── Bulles animées ────────────────────────────────────────────────────────
  final List<_BubbleData> _bubbles = [];
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();

    // Redirection vers login après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/login');
    });

    // Génère 14 bulles aléatoires
    final rand = Random();
    for (int i = 0; i < 14; i++) {
      _bubbles.add(_BubbleData(
        x: rand.nextDouble(), // position X (0.0 → 1.0)
        size: 5 + rand.nextDouble() * 14, // taille 5 → 19
        delay: rand.nextDouble() * 3000, // délai départ en ms
        duration: 3000 + rand.nextDouble() * 3000, // durée montée en ms
        opacity: 0.1 + rand.nextDouble() * 0.25,
      ));
    }

    // Controller global qui boucle
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Fond dégradé océan ───────────────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A3D8F),
                  Color(0xFF0D47A1),
                  Color(0xFF1155BB),
                  Color(0xFF082060),
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // ─── Rayon de lumière solaire ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.6,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.5),
                  radius: 0.85,
                  colors: [
                    Color(0x604DB6E8),
                    Color(0x3A1976D2),
                    Color(0x100D47A1),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ─── Bulles animées ───────────────────────────────────────────────
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, _) {
              return Stack(
                children: _bubbles.map((bubble) {
                  // Progression tenant compte du délai
                  final rawProgress =
                      (_bubbleController.value * 5000 - bubble.delay) /
                          bubble.duration;
                  final progress = rawProgress % 1.0;
                  if (progress < 0) return const SizedBox.shrink();

                  final yPos = size.height * (1.0 - progress * 1.1);
                  final xPos = bubble.x * size.width;

                  // Légère oscillation horizontale
                  final xOffset = sin(progress * pi * 4) * 6;

                  return Positioned(
                    left: xPos + xOffset,
                    top: yPos,
                    child: Opacity(
                      opacity:
                          (bubble.opacity * (1 - progress)).clamp(0.0, 1.0),
                      child: Container(
                        width: bubble.size,
                        height: bubble.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.2,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // ─── Ombres de poissons ───────────────────────────────────────────

          // Poisson 1 — grand, à droite
          Positioned(
            top: size.height * 0.07,
            right: 10,
            child: Opacity(
              opacity: 0.25,
              child: Transform.rotate(
                angle: -0.2,
                child: Image.asset(
                  'assets/images/fish1.png',
                  width: 80,
                  color: Color(0xFF061840),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Poisson 2 — moyen
          Positioned(
            top: size.height * 0.13,
            right: 90,
            child: Opacity(
              opacity: 0.15,
              child: Transform.rotate(
                angle: -0.1,
                child: Image.asset(
                  'assets/images/fish2.png',
                  width: 52,
                  color: Color(0xFF061840),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Poisson 3 — petit
          Positioned(
            top: size.height * 0.10,
            right: 175,
            child: Opacity(
              opacity: 0.10,
              child: Transform.rotate(
                angle: -0.15,
                child: Image.asset(
                  'assets/images/fish3.png',
                  width: 36,
                  color: Color(0xFF061840),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Poisson 4 — très petit, gauche
          Positioned(
            top: size.height * 0.09,
            left: 20,
            child: Opacity(
              opacity: 0.10,
              child: Transform.rotate(
                angle: 0.1,
                child: Image.asset(
                  'assets/images/fish3.png',
                  width: 30,
                  color: Color(0xFF061840),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // ─── Double vague en bas ──────────────────────────────────────────

          // Vague arrière (bleu clair)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(heightFactor: 0.52, invert: false),
              child: Container(
                height: 160,
                color: const Color(0xFF1565C0).withOpacity(0.55),
              ),
            ),
          ),

          // Vague avant (bleu très foncé)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(heightFactor: 0.65, invert: true),
              child: Container(
                height: 130,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF061840),
                      Color(0xFF04122E),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Contenu principal ────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ─── Logo avec halo brillant ────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.30),
                          blurRadius: 50,
                          spreadRadius: 12,
                        ),
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withOpacity(0.45),
                          blurRadius: 70,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_divine.png',
                      height: size.height * 0.26,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ─── Divine alimentation ──────────────────────────────────────────
                  const Text(
                    'Divine alimentation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Gestion de Ferme Piscicole',
                    style: TextStyle(
                      color: Color(0xFFBBDEFB),
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Données d'une bulle ──────────────────────────────────────────────────────
class _BubbleData {
  final double x;
  final double size;
  final double delay;
  final double duration;
  final double opacity;

  _BubbleData({
    required this.x,
    required this.size,
    required this.delay,
    required this.duration,
    required this.opacity,
  });
}

// ─── Clipper vague configurable ───────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  final double heightFactor;
  final bool invert;

  const _WaveClipper({required this.heightFactor, required this.invert});

  @override
  Path getClip(Size size) {
    final path = Path();
    final start = size.height * heightFactor;

    if (invert) {
      path.moveTo(0, start);
      path.quadraticBezierTo(
        size.width * 0.3,
        start - 30,
        size.width * 0.55,
        start,
      );
      path.quadraticBezierTo(
        size.width * 0.78,
        start + 28,
        size.width,
        start - 10,
      );
    } else {
      path.moveTo(0, start);
      path.quadraticBezierTo(
        size.width * 0.28,
        start - 35,
        size.width * 0.5,
        start,
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        start + 32,
        size.width,
        start - 8,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
