import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:router_game_f/components/color_button.dart';
import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/components/interface_infomation.dart';
import 'package:router_game_f/components/routing_item.dart';
import 'package:router_game_f/constants.dart';
import 'package:router_game_f/logger.dart';

bool isHovering = false;

class RouterNode extends Node with TapCallbacks {
  RouterNode({
    required super.id,
    required super.interfaces,
    super.maxNumberPortConnection = 4,
    this.routerInterval = 1,
  });

  /// ルータの動作間隔
  final double routerInterval;

  final List<RoutingItem> routingTable = [];

  final List<PositionComponent> _hoverInfo = [];

  /// ルータの動作に使用するタイマー
  late final Timer _routerTimer;

  /// バッファの数を表示するデバッグ用ラベル
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
        )..position = Vector2(width, 0 + (i * 18)),
    ]);

    addAll(routerNumber);
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    super.onHoverEnter(info);

    isHovering = true;

    if (_hoverInfo.isEmpty) {
      final hoverWidth = -width * 1.4 - 4;

      _hoverInfo.add(
        // 背景
        InterfaceInformation(onLeave: _hiveInterfaceInfo)
          ..position = Vector2(hoverWidth, 0),
      );

      for (var i = 0; i < interfaces.length; i++) {
        var colorButtonWidth = hoverWidth + 4;
        final buttonHeight = 26 + (52.0 * i);

        // ラベル と インターフェースカラーを追加
        _hoverInfo.add(
          TextComponent(
            text: '$i',
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )..position = Vector2(colorButtonWidth, 8 + (52.0 * i)),
        );

        final button = ColorButton(
          currentColor: interfaces[i].color,
          onTap: (color) {
            interfaces[i] = color == null
                ? interfaces[i].colorReset()
                : interfaces[i].copyWith(color: color);
          },
        )..position = Vector2(colorButtonWidth, buttonHeight);
        _hoverInfo.add(button);

        colorButtonWidth += 28;

        final routingItemByInterface = routingTable
            .where((element) => element.outputInterfaceNumber == i)
            .toList();

        for (var i = 0; i < routingItemByInterface.length; i++) {
          final routingItem = routingItemByInterface[i];

          _hoverInfo.add(
            ColorButton(
              currentColor: routingItem.color,
              onTap: (color) {
                final newItem = RoutingItem(
                  color: color ?? Colors.transparent,
                  outputInterfaceNumber: i,
                );

                routingTable
                  ..removeWhere(
                    (element) => element == routingItem || element == newItem,
                  )
                  ..add(newItem);
              },
            )..position = Vector2(colorButtonWidth, buttonHeight),
          );

          colorButtonWidth += 28;
        }

        // 追加用
        _hoverInfo.add(
          ColorButton(
            currentColor: Colors.transparent,
            onTap: (color) {
              final newItem = RoutingItem(
                color: color ?? Colors.transparent,
                outputInterfaceNumber: i,
              );

              routingTable
                ..removeWhere(
                  (element) => element == newItem,
                )
                ..add(newItem);
            },
          )..position = Vector2(colorButtonWidth, buttonHeight),
        );
      }

      addAll(_hoverInfo);
    }

    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    super.onHoverLeave(info);

    isHovering = false;

    _hiveInterfaceInfo();

    return true;
  }

  void _hiveInterfaceInfo() {
    Future.delayed(GameConstants.hoverUiDuration, () {
      // ホバーしているかどうか
      if (!isHovering && _hoverInfo.isNotEmpty) {
        _hoverInfo.map(remove).toList();
        _hoverInfo.clear();
      }
    });
  }

  void _toNextHop() {
    // パケット毎インターフェース毎にパケットが一致してるか検査
    // 1. パケットの色とインターフェースの色が一致していれば [connectedId] に送信
    // 2. 次のインターフェースで検査インターフェースがすべてチェック完了するまで 1 を繰り返す
    // 3. すべて精査し一致していなければパケットを破棄
    for (final packet in buffer) {
      for (var i = 0; i < interfaces.length; i++) {
        final interface = interfaces[i];

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

        final interfaceItem =
            routingTable.where((e) => e.outputInterfaceNumber == i);

        for (final item in interfaceItem) {
          if (item.color == packet.color) {
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
    }

    buffer.clear();
    onBuffer();
  }
}
