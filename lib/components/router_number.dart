import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:router_game_f/logger.dart';

// TODO(k-shir0): 当たり判定が終わっているので修正する
class RouterNumber extends PositionComponent with TapCallbacks {
  RouterNumber({
    this.onTap,
    required this.portNumber,
  });

  /// タップされたときに反応する関数
  void Function(TapDownEvent)? onTap;

  final int portNumber;

  @override
  double get width => 12;

  @override
  double get height => 12;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      TextComponent(
        text: 'ポート$portNumber',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );

    return null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    Logger.debug('click');

    onTap?.call(event);
  }
}
