import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';

class PCNode extends PositionComponent {
  // TODO(k-shir0): 表示を figma に揃える

  PCNode({
    required this.id,
    required this.self,
    this.defaultGatewayId,
    this.onTick,
  });

  final String id;
  final Packet self;
  final String? defaultGatewayId;

  final List<Packet> packets = [];
  final List<Packet> buffer = [];

  void Function(PCNode node)? onTick;

  /// パケットなどの生成に使用するタイマー
  late final Timer _intervalTimer;

  /// ルータの動作感覚
  late final Timer _routerTimer;

  late final TextComponent _packetLabel;
  late final TextComponent _bufferLabel;

  final _debugLabel = kDebugMode;

  @override
  double get width => 48;

  @override
  double get height => 48;

  @override
  Future<void>? onLoad() {
    final ShapeComponent shape;

    // ノードの形と色を決定
    switch (self.shape) {
      case Shape.square:
        shape = RectangleComponent(
          size: Vector2(48, 48),
          paint: Paint()
            ..color = self.color
            ..style = PaintingStyle.fill,
        );
        break;
      case Shape.circle:
        shape = CircleComponent(
          radius: width / 2,
          paint: Paint()
            ..color = self.color
            ..style = PaintingStyle.fill,
        );
        break;
    }
    add(shape);

    if (_debugLabel) {
      final idLabel = TextComponent(
        text: id,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 0);
      add(idLabel);

      _packetLabel = TextComponent(
        text: 'packets: ${packets.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 12);
      add(_packetLabel);

      _bufferLabel = TextComponent(
        text: 'buffer: ${buffer.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 24);
      add(_bufferLabel);
    }

    _intervalTimer = Timer(
      3,
      onTick: () => onTick?.call(this),
      repeat: true,
    );

    _routerTimer = Timer(
      3,
      onTick: _toNextHop,
      repeat: true,
    );

    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _intervalTimer.update(dt);
    _routerTimer.update(dt);

    if (_debugLabel) {
      _packetLabel.text = 'packets: ${packets.length}';
      _bufferLabel.text = 'buffer: ${buffer.length}';
    }
  }

  void _toNextHop() {
    final nextHop = parent?.children
        .query<PCNode>()
        .firstWhereOrNull((element) => element.id == defaultGatewayId);

    packets.addAll(buffer);
    buffer.clear();

    if (nextHop != null) {
      // 以下パケットの処理
      for (final packet in packets) {
        // 色と図形が一致しているか
        if (self.color == packet.color && self.shape == packet.shape) {
          // 一致
          print('$id: 処理');
        } else {
          // 次のノードにパケットを渡す

          print('$id: バッファに追加');
          nextHop.buffer.add(packet);
        }
      }
    }
    // TODO(k-shir0): ここで clear するのはまずそう（未検証）
    packets.clear();
  }
}
