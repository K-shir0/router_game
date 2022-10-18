import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import 'package:flutter/material.dart';

class ColorButton extends PositionComponent with TapCallbacks {
  ColorButton({
    this.currentColor,
    this.onTap,
  });

  void Function(Color?)? onTap;

  @override
  double get width => 24;

  @override
  double get height => 24;

  late CircleComponent _currentComponent;

  Color? currentColor;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    _currentComponent = CircleComponent(
      radius: width / 2,
      paint: Paint()..color = currentColor ?? Colors.transparent,
    );

    add(_currentComponent);

    return null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (currentColor == null) {
      currentColor = Colors.red;
    } else if (currentColor == Colors.red) {
      currentColor = Colors.greenAccent;
    } else if (currentColor == Colors.greenAccent) {
      currentColor = Colors.blue;
    } else if (currentColor == Colors.blue) {
      currentColor = null;
    }

    _currentComponent.paint = Paint()
      ..color = currentColor ?? Colors.transparent;

    onTap?.call(currentColor);
  }
}
