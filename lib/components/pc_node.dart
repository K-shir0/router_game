import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';

// TODO(k-shir0): 表示を figma に揃える
class PCNode extends Node with TapCallbacks {
  PCNode({
    required super.id,
    required super.interfaces,
    super.maxNumberPortConnection = 1,
    super.interfaceColorOverrideGuard = true,
    required this.self,
    this.onTick,
    this.timerInterval = 3,
    this.routerInterval = 3,
  });

  /// 自分自身の処理できるパケットのタイプ
  final PacketData self;

  void Function(PCNode node)? onTick;

  /// タイマーの動作間隔
  final double timerInterval;

  /// パケットなどの生成に使用するタイマー
  late final Timer _timer;

  /// ルータの動作間隔
  final double routerInterval;

  /// ルータの動作に使用するタイマー
  late final Timer _routerTimer;

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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    if (!isPortSetting(0)) {
      // TODO(k-shir0): copyWith 使いたい
      interfaces[0] = interfaces[0].copyWith(color: self.color);
    }

    final ShapeComponent shape;

    // ノードの形と色を決定
    switch (self.shape) {
      case PacketShape.square:
        shape = RectangleComponent(
          size: Vector2(48, 48),
          paint: Paint()
            ..color = self.color
            ..style = PaintingStyle.fill,
        );
        break;
      case PacketShape.circle:
        shape = CircleComponent(
          radius: width / 2,
          paint: Paint()
            ..color = self.color
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

      _bufferCountLabel = TextComponent(
        text: 'buffer: ${buffer.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 12);
      add(_bufferCountLabel);

      _resolvedPacketCountLabel = TextComponent(
        text: 'resolved: $_resolvedPacketCount',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 24);
      add(_resolvedPacketCountLabel);
    }

    _timer = Timer(
      timerInterval,
      onTick: () => {onTick?.call(this), onBuffer()},
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
      _bufferCountLabel.text = 'buffer: ${buffer.length}';
      _resolvedPacketCountLabel.text = 'resolved: $_resolvedPacketCount';
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // TODO(k-shir0): 複数存在する場合は考慮する
    onConnect(portNumber: 0);
  }

  void _toNextHop() {
    // TODO(k-shir0): 複数存在する場合は考慮する
    final interface = interfaces.firstOrNull;

    if (interface == null) return;

    final nextHop = parent?.children
        .query<Node>()
        .firstWhereOrNull((e) => e.id == interface.defaultGatewayId);

    if (nextHop != null) {
      // 以下パケットの処理
      for (final packet in buffer) {
        // 色と図形が一致しているか
        if (self.color == packet.color && self.shape == packet.shape) {
          // 一致
          _resolvedPacketCount += 1;
        } else {
          // TODO(k-shir0): 送信元チェック
          if (packet.sourceId != nextHop.id) {
            parent?.add(
              PacketComponent(
                data: packet,
                from: center,
                to: nextHop.center,
                onComplete: () {
                  // 次のノードにパケットを渡す
                  nextHop.buffer.add(packet.copyWith(sourceId: id));
                  nextHop.onBuffer();
                },
              ),
            );
          }
        }
      }

      buffer.clear();
    }

    onBuffer();
  }
}
