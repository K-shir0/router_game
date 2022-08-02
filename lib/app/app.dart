import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/app/micro_traffic_debug_page.dart';
import 'package:router_game_f/app/micro_traffic_game_page.dart';
import 'package:router_game_f/game.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    this.debugMode = kDebugMode,
  });

  final bool debugMode;

  @override
  Widget build(BuildContext context) {
    final page = debugMode
        ? const MicroTrafficDebugPage()
        : MicroTrafficGamePage(game: MyGame());

    return MaterialApp(
      home: page,
    );
  }
}
