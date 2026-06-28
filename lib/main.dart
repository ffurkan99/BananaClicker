import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'app.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize GameController (Initialization happens in SplashScreen)
  final gameController = GameController();

  // 3. Run the App
  runApp(
    ChangeNotifierProvider<GameController>.value(
      value: gameController,
      child: const MyApp(),
    ),
  );
}


