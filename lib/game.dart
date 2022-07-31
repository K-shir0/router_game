import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

import 'package:flutter/material.dart';

enum Shape {
  square,
  circle,
}

class Packet {
  const Packet({
    required this.color,
    required this.shape,
  });

  final Color color;
  final Shape shape;
}

class Node extends PositionComponent {
  Node({
    required this.id,
    required this.packets,
    required this.self,
  });

  final String id;
  final List<Packet> packets;
  final List<Packet> buffer = [];
  final Packet self;

  @override
  Future<void>? onLoad() {
    super.onLoad();

    RectangleComponent(
      size: Vector2(10, 10),
      paint: Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    ).anchor = Anchor.center;

    return null;
  }
}

class PC extends Node {
  PC({
    required super.id,
    required super.packets,
    required super.self,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        width,
        height,
      ),
      Paint()..color = Colors.red,
    );
  }
}

class Router extends Node {
  Router({
    required super.id,
    required super.packets,
    required super.self,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = Colors.blue,
    );
  }
}

class PacketComponent extends PositionComponent {
  PacketComponent({required this.id});

  final String id;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = Colors.blue,
    );
  }
}

class NodeLine extends PositionComponent {
  NodeLine({required this.start, required this.end});

  final PositionComponent start;
  final PositionComponent end;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      start.toRect().center,
      end.toRect().center,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 12,
    );
  }
}

class MyGame extends FlameGame {
  final List<List<String>> vertexes = [
    ['pc0', 'pc1']
  ];

  late final Timer interval;

  @override
  bool get debugMode => true;

  @override
  Color backgroundColor() => const Color(0x00F2F2F2);

  @override
  Future<void> onLoad() async {
    final router0 = Router(
      id: 'router0',
      packets: [],
      self: const Packet(color: Colors.blue, shape: Shape.square),
    )
      ..size = Vector2(72, 72)
      ..position = Vector2(100, 0);
    await add(router0);

    final pc0 = PC(
      id: 'pc0',
      packets: [const Packet(color: Colors.red, shape: Shape.circle)],
      self: const Packet(color: Colors.red, shape: Shape.square),
    )
      ..size = Vector2(48, 48)
      ..position = Vector2(0, 100);
    await add(pc0);

    final pc1 = PC(
      id: 'pc1',
      packets: [],
      self: const Packet(color: Colors.red, shape: Shape.circle),
    )
      ..size = Vector2(48, 48)
      ..position = Vector2(200, 200);
    await add(pc1);

    final line = NodeLine(
      start: pc0,
      end: router0,
    );
    await add(line);

    final packet = PacketComponent(id: 'packet')
      ..size = Vector2(24, 24)
      // pc0 center
      ..position = pc0.center + Vector2(-12, -12);
    await add(packet);

    // // デバッグ系統
    // final fps = FpsTextComponent();
    // add(fps);
    //
    // final totalPacketLabel = TextComponent(text: 'total packet:')
    //   ..position = Vector2(0, fps.height);
    // add(totalPacketLabel);
    // final totalPacketNumber = TextComponent(text: '0')
    //   ..position = Vector2(
    //       totalPacketLabel.x + totalPacketLabel.width, totalPacketLabel.y);
    // add(totalPacketNumber);

    interval = Timer(
      5,
      onTick: () {
        isAdded = false;
      },
      repeat: true,
    );
  }

  bool isAdded = true;

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    final nodes = children.query<Node>();
    // final texts = children.query<TextComponent>();
    // final totalPackets =
    // nodes.map((node) => node.packets.length).reduce((a, b) => a + b);
    // texts[1].text = totalPackets.toString();

    // final totalBuffers = nodes.map((node) => node.buffer.length).reduce((a, b) => a + b);
    for (final node in nodes) {
      if (node.packets.isEmpty) {
        continue;
      }

      // ルータの形と色が一致していなければ隣にパケットを移動する
      final packets = node.packets;
      for (final packet in packets) {
        if (packet.shape != node.self.shape ||
            packet.color != node.self.color) {
          // 色と形が一致しなかったときの処理
          final vertex =
              vertexes.firstWhere((vertex) => vertex.contains(node.id));
          final nextNodeId = vertex[vertex.indexOf(node.id) + 1];
          final nextNode = nodes.firstWhere((node) => node.id == nextNodeId);
          nextNode.buffer.add(packet);
        } else {
          // TODO(k-shir0): 一致したときの処理
        }
      }
      node.packets.clear();
    }

    // TODO(k-shir0): これは最初に持って行くと良さそう
    // 処理完了フェーズ
    for (final node in nodes) {
      node.packets.clear();
      node.packets.addAll(node.buffer);
      node.buffer.clear();
    }

    // パケットを生み出すフェーズ
    if (!isAdded) {
      final pc0 = children.query<Node>().firstWhere((node) => node.id == 'pc0');
      pc0.packets.add(const Packet(color: Colors.red, shape: Shape.circle));

      isAdded = true;
    }
  }
}
