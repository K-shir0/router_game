import 'package:flutter/material.dart';

import 'package:router_game_f/app/micro_traffic_game_page.dart';
import 'package:router_game_f/game.dart';
import 'package:router_game_f/node_to_node.dart';

class MicroTrafficDebugPage extends StatelessWidget {
  const MicroTrafficDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('ゲーム開始'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => MicroTrafficGamePage(
                  game: MyGame(),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('1ノードと1ノード'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => MicroTrafficGamePage(
                  game: NodeToNode(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
