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
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFE5E6E6),
    );
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
