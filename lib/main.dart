import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/game.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}