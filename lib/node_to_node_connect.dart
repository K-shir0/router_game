import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/constants/constants.dart';
import 'package:router_game_f/logger.dart';

/// ノードの選択に使う変数
String? selectedId;

int? selectedPortNumber;

Component? selectedInfo;

class NodeToNodeConnect extends FlameGame with HasTappableComponents {
  @override
  Color backgroundColor() => GameColors.backgroundColor;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    Logger.debug(event.canvasPosition.toString());
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    await add(
      PCNode(
        id: 'PC0',
        self: const Packet(
          color: Colors.blue,
          shape: PacketShape.square,
        ),
        onTick: (node) {
          node.buffer.add(
            const Packet(
              color: Colors.blue,
              shape: PacketShape.circle,
            ),
          );
        },
        interfaces: [],
      )..position = Vector2(12, 100),
    );

    await add(
      PCNode(
        id: 'PC1',
        self: const Packet(
          color: Colors.blue,
          shape: PacketShape.circle,
        ),
        interfaces: [],
      )..position = Vector2(200, 300),
    );
  }
}
