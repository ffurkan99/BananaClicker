import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'app.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize GameController and load state
  final gameController = GameController();
  await gameController.initGame();

  // 3. Run the App
  runApp(
    ChangeNotifierProvider<GameController>.value(
      value: gameController,
      child: const MyApp(),
    ),
  );
}


