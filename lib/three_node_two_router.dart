import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/constants/constants.dart';

class ThreeNodeTwoRouter extends FlameGame
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
              color: Colors.purpleAccent,
              shape: PacketShape.circle,
            ),
          );
        },
      )..position = Vector2(12, 100),
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
          const Interface(
            id: 'R0-2',
            color: Colors.purpleAccent,
            connectedId: 'Router1',
            defaultGatewayId: null,
          ),
        ],
      )..position = Vector2(0, 250),
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
            const PacketData(
              color: Colors.purpleAccent,
              shape: PacketShape.circle,
            ),
          );
        },
      )..position = Vector2(200, 300),
    );

    await add(
      RouterNode(
        id: 'Router1',
        interfaces: [
          const Interface(
            id: 'R1-0',
            color: Colors.purpleAccent,
            connectedId: 'PC2',
            defaultGatewayId: null,
          ),
          const Interface(
            id: 'R1-1',
            color: Colors.blue,
            connectedId: 'Router0',
            defaultGatewayId: null,
          ),
          const Interface(
            id: 'R2',
            color: Colors.greenAccent,
            connectedId: 'Router0',
            defaultGatewayId: null,
          ),
        ],
      )..position = Vector2(0, 500),
    );

    await add(
      PCNode(
        id: 'PC2',
        self: const PacketData(
          color: Colors.purpleAccent,
          shape: PacketShape.circle,
        ),
        interfaces: [
          const Interface(
            id: 'P2-0',
            color: Colors.purpleAccent,
            connectedId: 'Router1',
            defaultGatewayId: 'Router1',
          )
        ],
        onTick: (node) {
          node.buffer.add(
            const PacketData(color: Colors.blue, shape: PacketShape.square),
          );
        },
      )..position = Vector2(120, 600),
    );
  }
}
