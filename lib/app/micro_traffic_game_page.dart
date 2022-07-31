import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/game.dart';

class MicroTrafficGamePage extends StatelessWidget {
  const MicroTrafficGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: MyGame(),
      ),
    );
  }
}
