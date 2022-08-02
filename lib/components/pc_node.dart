import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/logger.dart';

class PCNode extends Node {
  // TODO(k-shir0): 表示を figma に揃える

  PCNode({
    required super.id,
    required this.self,
    this.defaultGatewayId,
    this.onTick,
    this.timerInterval = 3,
    this.routerInterval = 3,
  });

  /// 自分自身の処理できるパケットのタイプ
  final Packet self;

  /// パケットを次に送るID
  final String? defaultGatewayId;

  void Function(PCNode node)? onTick;

  /// タイマーの動作間隔
  final double timerInterval;

  /// パケットなどの生成に使用するタイマー
  late final Timer _timer;

  /// ルータの動作間隔
  final double routerInterval;

  /// ルータの動作に使用するタイマー
  late final Timer _routerTimer;

  /// パケットの数を表示するラベル
  late final TextComponent _packetCountLabel;

  /// バッファの数を表示するラベル
  late final TextComponent _bufferCountLabel;

  var _resolvedPacketCount = 0;

  /// パケットの処理数を表示するラベル
  late final TextComponent _resolvedPacketCountLabel;

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
      case Shape.triangle:
        // TODO(k-shir0): 本当の正三角形ではない
        shape = PolygonComponent(
          [
            Vector2(height / 2, 0),
            Vector2(width, height),
            Vector2(0, height),
          ],
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

      _packetCountLabel = TextComponent(
        text: 'packets: ${packets.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 12);
      add(_packetCountLabel);

      _bufferCountLabel = TextComponent(
        text: 'buffer: ${buffer.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 24);
      add(_bufferCountLabel);

      _resolvedPacketCountLabel = TextComponent(
        text: 'resolved: $_resolvedPacketCount',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 36);
      add(_resolvedPacketCountLabel);
    }

    _timer = Timer(
      timerInterval,
      onTick: () => onTick?.call(this),
      repeat: true,
    );

    _routerTimer = Timer(
      routerInterval,
      onTick: _toNextHop,
      repeat: true,
    );

    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer.update(dt);
    _routerTimer.update(dt);

    if (_debugLabel) {
      _packetCountLabel.text = 'packets: ${packets.length}';
      _bufferCountLabel.text = 'buffer: ${buffer.length}';
      _resolvedPacketCountLabel.text = 'resolved: $_resolvedPacketCount';
    }
  }

  void _toNextHop() {
    final nextHop = parent?.children
        .query<Node>()
        .firstWhereOrNull((e) => e.id == defaultGatewayId);

    if (nextHop != null) {
      packets.addAll(buffer);
      buffer.clear();

      // 以下パケットの処理
      for (final packet in packets) {
        // 色と図形が一致しているか
        if (self.color == packet.color && self.shape == packet.shape) {
          // 一致
          Logger.debug('[$id] パケット処理完了');
          _resolvedPacketCount += 1;
        } else {
          // TODO(k-shir0): 送信元チェック
          if (packet.sourceId != nextHop.id) {
            // 次のノードにパケットを渡す
            Logger.debug('[$id] 送信 $packet to $nextHop');
            nextHop.buffer.add(packet.copyWith(sourceId: id));
          }
        }
      }

      packets.clear();
    }
  }
}
