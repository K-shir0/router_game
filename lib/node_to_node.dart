import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/components/interface.dart';
import 'package:router_game_f/constants/constants.dart';

/// 1ノードと1ノードのみを持つゲーム
class NodeToNode extends FlameGame with HasTappableComponents {
  @override
  Color backgroundColor() => GameColors.backgroundColor;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    await add(
      PCNode(
        id: 'PC0',
        self: const Packet(
          color: Colors.red,
          shape: PacketShape.square,
        ),
        interfaces: [
          Interface(
            color: Colors.red,
            connectedId: 'PC1',
            defaultGatewayId: 'PC1',
          )
        ],
        onTick: (node) {
          node.buffer.add(
            const Packet(color: Colors.red, shape: PacketShape.circle),
          );
        },
      )..position = Vector2(0, 100),
    );

    await add(
      PCNode(
        id: 'PC1',
        self: const Packet(
          color: Colors.red,
          shape: PacketShape.circle,
        ),
        interfaces: [
          Interface(
            color: Colors.red,
            connectedId: 'PC0',
            defaultGatewayId: 'PC0',
          )
        ],
      )..position = Vector2(0, 300),
    );

    return;
  }
}
