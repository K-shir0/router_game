import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/constants/constants.dart';

/// 1ノードと1ノードのみを持つゲーム
class NodeToNode extends FlameGame with HasTappableComponents, HasHoverables {
  @override
  Color backgroundColor() => GameColors.backgroundColor;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final pc0 = PCNode(
      id: 'PC0',
      self: const PacketData(
        color: Colors.red,
        shape: PacketShape.square,
      ),
      interfaces: [
        const Interface(
          id: '0',
          color: Colors.red,
          connectedId: 'PC1',
          defaultGatewayId: 'PC1',
        )
      ],
      onTick: (node) {
        node.buffer.add(
          const PacketData(color: Colors.red, shape: PacketShape.circle),
        );
      },
    )..position = Vector2(0, 100);

    final pc1 = PCNode(
      id: 'PC1',
      self: const PacketData(
        color: Colors.red,
        shape: PacketShape.circle,
      ),
      interfaces: [
        const Interface(
          id: '1',
          color: Colors.red,
          connectedId: 'PC0',
          defaultGatewayId: 'PC0',
        )
      ],
    )..position = Vector2(0, 300);

    await add(pc0);
    await add(pc1);

    await add(
      Cable(
        start: pc0,
        end: pc1,
        startInterfaceId: '0',
        endInterfaceId: '1',
      ),
    );

    // pc0 to pc1 connect line flame

    return;
  }
}
