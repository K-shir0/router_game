import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/components/router_add_button.dart';
import 'package:router_game_f/constants/constants.dart';
import 'package:uuid/uuid.dart';

class TwoNodeOneRouterConnect extends FlameGame
    with HasTappableComponents, HasHoverables {
  @override
  Color backgroundColor() => GameColors.backgroundColor;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (routerAddMode) {
      // モードで分ける
      add(
        RouterNode(
          id: const Uuid().v4(),
          interfaces: [],
        )
          ..position = event.canvasPosition - Vector2(72, 72) / 2,
      );

      routerAddMode = false;
    }
  }

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
        onTick: (node) {
          node.buffer.add(
            const PacketData(
              color: Colors.greenAccent,
              shape: PacketShape.square,
            ),
          );
        },
        interfaces: [],
      )..position = Vector2(0, 100),
    );

    await add(
      RouterNode(
        id: 'Router0',
        interfaces: [],
      )..position = Vector2(0, 300),
    );

    await add(
      PCNode(
        id: 'PC1',
        self: const PacketData(
          color: Colors.greenAccent,
          shape: PacketShape.square,
        ),
        onTick: (node) {
          node.buffer.add(
            const PacketData(color: Colors.blue, shape: PacketShape.square),
          );
        },
        interfaces: [],
      )..position = Vector2(200, 400),
    );

    await add(
      RouterAddButton()..position = Vector2(0, 0),
    );

    return;
  }

  @override
  void update(double dt) {
    super.update(dt);

    children.query<PCNode>().map((e) => e.update(dt));
  }
}
