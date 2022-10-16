import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:router_game_f/components/components.dart';

class PacketView extends PositionComponent {
  PacketView({required this.data});

  final PacketData data;

  @override
  Future<void>? onLoad() {
    super.onLoad();

    final ShapeComponent shape;

    // ノードの形と色を決定
    switch (data.shape) {
      case PacketShape.square:
        shape = RectangleComponent(
          size: Vector2(width, height),
          paint: Paint()
            ..color = data.color
            ..style = PaintingStyle.fill,
        );
        break;
      case PacketShape.circle:
        shape = CircleComponent(
          radius: width / 2,
          paint: Paint()
            ..color = data.color
            ..style = PaintingStyle.fill,
        );
        break;
      case PacketShape.triangle:
        // TODO(k-shir0): 本当の正三角形ではない
        shape = PolygonComponent(
          [
            Vector2(height / 2, 0),
            Vector2(width, height),
            Vector2(0, height),
          ],
          paint: Paint()
            ..color = data.color
            ..style = PaintingStyle.fill,
        );
        break;
    }
    add(shape);

    return null;
  }
}
