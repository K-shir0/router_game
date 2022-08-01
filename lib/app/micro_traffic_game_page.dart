import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MicroTrafficGamePage extends StatelessWidget {
  const MicroTrafficGamePage({
    super.key,
    required this.game,
  });

  final FlameGame game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
      ),
    );
  }
}
