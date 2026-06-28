import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _loadApp();
  }

  Future<void> _loadApp() async {
    // Wait for BOTH the game to initialize and a minimum visual delay of 1.5s
    await Future.wait([
      context.read<GameController>().initGame(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const BananaClickerApp(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.darkBrown, // Dark background for the splash
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              // App Title
              Text(
                'Banana Clicker',
                style: PixelTheme.pixelStyle(
                  fontSize: 24,
                  color: PixelColors.pixelGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Loading...',
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
                  color: PixelColors.creamWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
