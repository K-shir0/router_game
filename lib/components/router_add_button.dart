import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

bool routerAddMode = false;

class RouterAddButton extends PositionComponent with TapCallbacks {
  RouterAddButton();

  @override
  double get width => 40;

  @override
  double get height => 40;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      CircleComponent(
        radius: 20,
        paint: Paint()..color = Colors.red,
      ),
    );

    return null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // グローバルのタップが反応してしまうため遅らせている
    // あまり Duration を使うのは良くない
    Future.delayed(const Duration(milliseconds: 100), () {
      routerAddMode = true;
    });
  }
}
