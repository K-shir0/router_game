import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/app/micro_traffic_debug_page.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    this.debugMode = kDebugMode,
  });

  final bool debugMode;

  @override
  Widget build(BuildContext context) {
    // TODO(k-shir0): 常にデバッグモード起動なので本番時は切り替えるように変更
    // const が付いていることに注意（削除すれば動く）
    const page = MicroTrafficDebugPage();
    // final page = debugMode
    //     ? const MicroTrafficDebugPage()
    //     : MicroTrafficGamePage(game: MyGame());

    return const MaterialApp(
      home: page,
    );
  }
}
