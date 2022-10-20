import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/constants.dart';

class TwoNodeOneRouter extends FlameGame
    with HasTappableComponents, HasHoverables {
  @override
  Color backgroundColor() => GameColors.backgroundColor;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    await add(
      PCNode(
        id: 'PC0',
        self: const PacketData(
          color: Colors.blue,
          shape: PacketShape.square,
        ),
        interfaces: [
          const Interface(
            id: 'P0-0',
            color: Colors.blue,
            connectedId: 'Router0',
            defaultGatewayId: 'Router0',
          )
        ],
        onTick: (node) {
          node.buffer.add(
            const PacketData(
              color: Colors.greenAccent,
              shape: PacketShape.square,
            ),
          );
        },
      )..position = Vector2(0, 100),
    );

    await add(
      RouterNode(
        id: 'Router0',
        interfaces: [
          const Interface(
            id: 'R0-0',
            color: Colors.blue,
            connectedId: 'PC0',
            defaultGatewayId: null,
          ),
          const Interface(
            id: 'R0-1',
            color: Colors.greenAccent,
            connectedId: 'PC1',
            defaultGatewayId: null,
          ),
        ],
      )..position = Vector2(0, 300),
    );

    await add(
      PCNode(
        id: 'PC1',
        self: const PacketData(
          color: Colors.greenAccent,
          shape: PacketShape.square,
        ),
        interfaces: [
          const Interface(
            id: 'P1-0',
            color: Colors.greenAccent,
            connectedId: 'Router0',
            defaultGatewayId: 'Router0',
          )
        ],
        onTick: (node) {
          node.buffer.add(
            const PacketData(color: Colors.blue, shape: PacketShape.square),
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
