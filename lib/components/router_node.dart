import 'package:collection/collection.dart';

import 'package:flame/components.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/components/interface.dart';
import 'package:router_game_f/logger.dart';

class RouterNode extends Node {
  RouterNode({
    required super.id,
    required this.interfaces,
    this.routerInterval = 1,
  });

  final List<Interface> interfaces;

  /// ルータの動作間隔
  final double routerInterval;

  /// ルータの動作に使用するタイマー
  late final Timer _routerTimer;

  /// パケットの数を表示するラベル
  late final TextComponent _packetCountLabel;

  /// バッファの数を表示するラベル
  late final TextComponent _bufferCountLabel;

  final _debugLabel = kDebugMode;

  @override
  double get width => 72;

  @override
  double get height => 72;

  @override
  Future<void>? onLoad() async {
    await add(
      CircleComponent(
        radius: width / 2,
        paint: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ),
    );

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
      await add(idLabel);

      _packetCountLabel = TextComponent(
        text: 'packets: ${packets.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 12);
      await add(_packetCountLabel);

      _bufferCountLabel = TextComponent(
        text: 'buffer: ${buffer.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 24);
      await add(_bufferCountLabel);
    }

    _routerTimer = Timer(
      routerInterval,
      onTick: _toNextHop,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _routerTimer.update(dt);

    if (_debugLabel) {
      _packetCountLabel.text = 'packets: ${packets.length}';
      _bufferCountLabel.text = 'buffer: ${buffer.length}';
    }
  }

  void _toNextHop() {
    packets.addAll(buffer);
    buffer.clear();

    // パケット毎インターフェース毎にパケットが一致してるか検査
    // 1. パケットの色とインターフェースの色が一致していれば [connectedId] に送信
    // 2. 次のインターフェースで検査インターフェースがすべてチェック完了するまで 1 を繰り返す
    // 3. すべて精査し一致していなければパケットを破棄
    for (final packet in packets) {
      for (final interface in interfaces) {
        if (interface.color == packet.color) {
          final nextHop = parent?.children
              .query<Node>()
              .firstWhereOrNull((e) => e.id == interface.connectedId);

          if (nextHop != null) {
            Logger.debug('[$id] 送信 to ${interface.connectedId}');

            nextHop.buffer.add(packet);
          }
        }
      }
    }

    packets.clear();
  }
}
