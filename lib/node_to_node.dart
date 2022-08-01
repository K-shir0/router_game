import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

enum Shape {
  square,
  circle,
}

class Packet extends Equatable {
  const Packet({
    required this.color,
    required this.shape,
    this.dt,
  });

  final Color color;
  final Shape shape;
  final double? dt;

  @override
  List<Object?> get props => [color, shape, dt];

  Packet copyWith({
    Color? color,
    Shape? shape,
    double? dt,
  }) {
    return Packet(
      color: color ?? this.color,
      shape: shape ?? this.shape,
      dt: dt ?? this.dt,
    );
  }
}

class Node extends PositionComponent {
  void toNextHop(double dt) {}
}

class PCNode extends Node {
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

  late final Timer intervalTimer;

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

    intervalTimer = Timer(
      3,
      onTick: () => onTick?.call(this),
      repeat: true,
    );

    _routerTimer = Timer(3);

    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    intervalTimer.update(dt);
    _routerTimer.update(dt);

    if (_routerTimer.finished) {
      toNextHop(dt);
      _routerTimer.start();
    }

    if (_debugLabel) {
      _packetLabel.text = 'packets: ${packets.length}';
      _bufferLabel.text = 'buffer: ${buffer.length}';
    }
  }

  @override
  void toNextHop(double dt) {
    // TODO(k-shir0): dt で処理するのは間違っていた

    final nextHop = parent?.children
        .query<PCNode>()
        .firstWhereOrNull((element) => element.id == defaultGatewayId);

    print(dt);
    packets.addAll(buffer.where((e) => e.dt != dt));
    buffer.removeWhere((e) => e.dt != dt || e.dt == null);

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
          nextHop.buffer.add(packet.copyWith(dt: dt));
        }
      }
    }
    // TODO(k-shir0): ここで clear するのはまずそう（未検証）
    packets.clear();
  }
}

/// 1ノードと1ノードのみを持つゲーム
class NodeToNode extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00F2F2F2);

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      PCNode(
        id: 'PC0',
        self: const Packet(
          color: Colors.red,
          shape: Shape.square,
        ),
        defaultGatewayId: 'PC1',
        onTick: (node) {
          node.buffer.add(
            const Packet(color: Colors.red, shape: Shape.circle),
          );
        },
      )..position = Vector2(0, 100),
    );

    add(
      PCNode(
        id: 'PC1',
        self: const Packet(
          color: Colors.red,
          shape: Shape.circle,
        ),
        defaultGatewayId: 'PC0',
      )..position = Vector2(0, 300),
    );

    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final pcAry = children.query<PCNode>();

    for (final pc in pcAry) {
      pc.intervalTimer.update(dt);
    }
  }
}
