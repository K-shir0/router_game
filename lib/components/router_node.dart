import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/logger.dart';

class RouterNode extends Node with TapCallbacks {
  RouterNode({
    required super.id,
    required super.interfaces,
    super.maxNumberPortConnection = 4,
    this.routerInterval = 1,
  });

  /// ルータの動作間隔
  final double routerInterval;

  /// ルータの動作に使用するタイマー
  late final Timer _routerTimer;

  /// バッファの数を表示するラベル
  late final TextComponent _bufferCountLabel;

  final _debugLabel = kDebugMode;

  @override
  double get width => 72;

  @override
  double get height => 72;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

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

      _bufferCountLabel = TextComponent(
        text: 'buffer: ${buffer.length}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(width, 12);
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
      _bufferCountLabel.text = 'buffer: ${buffer.length}';
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final routerNumber = <RouterNumber>[];

    routerNumber.addAll([
      for (var i = 0; i < maxNumberPortConnection; i++)
        RouterNumber(
          portNumber: i,
          onTap: (event) {
            // タップしたときにメニューを削除
            removeAll(routerNumber);

            onConnect(portNumber: i);

            Logger.debug(interfaces[0].defaultGatewayId.toString());
          },
        )..position = Vector2(x + width, 0 + (i * 18)),
    ]);

    addAll(routerNumber);
  }

  void _toNextHop() {
    // パケット毎インターフェース毎にパケットが一致してるか検査
    // 1. パケットの色とインターフェースの色が一致していれば [connectedId] に送信
    // 2. 次のインターフェースで検査インターフェースがすべてチェック完了するまで 1 を繰り返す
    // 3. すべて精査し一致していなければパケットを破棄
    for (final packet in buffer) {
      for (final interface in interfaces) {
        if (interface.color == packet.color) {
          final nextHop = parent?.children
              .query<Node>()
              .firstWhereOrNull((e) => e.id == interface.connectedId);

          if (nextHop != null) {
            if (packet.sourceId != interface.connectedId) {
              Logger.debug('[$id] 送信 to ${interface.connectedId}');

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
      }
    }

    buffer.clear();
    onBuffer();
  }
}
