import 'package:flame/components.dart';

import 'package:flutter/material.dart';

class GameCard extends PositionComponent {
  GameCard();

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
}
