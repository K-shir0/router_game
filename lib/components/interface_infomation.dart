import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/router_node.dart';

class InterfaceInformation extends PositionComponent with Hoverable {
  InterfaceInformation({this.onLeave});

  void Function()? onLeave;

  @override
  double get width => 100;

  @override
  double get height => 216;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      RectangleComponent(
        size: Vector2(width, height),
        paint: Paint()
          ..color = const Color(0xFFE5E6E6)
          ..style = PaintingStyle.fill,
      ),
    );

    return null;
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    super.onHoverEnter(info);

    isHovering = true;

    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    super.onHoverLeave(info);

    isHovering = false;

    onLeave?.call();

    return true;
  }
}
