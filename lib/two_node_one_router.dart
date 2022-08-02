import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/components/interface.dart';
import 'package:router_game_f/constants/constants.dart';

class TwoNodeOneRouter extends FlameGame {
  @override
  Color backgroundColor() => GameColors.backgroundColor;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    await add(
      PCNode(
        id: 'PC0',
        self: const Packet(
          color: Colors.blue,
          shape: Shape.square,
        ),
        defaultGatewayId: 'Router0',
        onTick: (node) {
          node.buffer.add(
            const Packet(color: Colors.greenAccent, shape: Shape.square),
          );
        },
      )..position = Vector2(0, 100),
    );

    await add(
      RouterNode(
        id: 'Router0',
        interfaces: [
          Interface(color: Colors.blue, connectedId: 'PC0'),
          Interface(color: Colors.greenAccent, connectedId: 'PC1'),
        ],
      )..position = Vector2(0, 300),
    );

    await add(
      PCNode(
        id: 'PC1',
        self: const Packet(
          color: Colors.greenAccent,
          shape: Shape.square,
        ),
        defaultGatewayId: 'Router0',
        onTick: (node) {
          node.buffer.add(
            const Packet(color: Colors.blue, shape: Shape.square),
          );
        },
      )..position = Vector2(200, 400),
    );

    return;
  }

  @override
  void update(double dt) {
    super.update(dt);

    children.query<PCNode>().map((e) => e.update(dt));
  }
}