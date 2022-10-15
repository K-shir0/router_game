import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/node_to_node_connect.dart';

import 'package:uuid/uuid.dart';

class Node extends PositionComponent with Hoverable {
  Node({
    required this.id,
    required this.interfaces,
    required this.maxNumberPortConnection,
    this.interfaceColorOverrideGuard = false,
  });

  /// 識別するためのID
  final String id;

  ///　ノードが持つインターフェース
  final List<Interface> interfaces;

  /// 送られたパケットを保存しておくバッファ
  final List<Packet> buffer = [];

  /// ポートの最大接続数
  final int maxNumberPortConnection;

  final List<Component> infos = [];

  final bool interfaceColorOverrideGuard;

  @override
  Future<void>? onLoad() {
    super.onLoad();

    interfaces.addAll([
      for (int i = 0; i < maxNumberPortConnection - interfaces.length; i++)
        Interface(
          id: const Uuid().v4(),
          color: null,
          connectedId: null,
          defaultGatewayId: null,
        )
    ]);

    return null;
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    super.onHoverEnter(info);

    var count = 0;

    final id = TextComponent(
      text: this.id,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.deepOrange,
          fontSize: 12,
        ),
      ),
    )..position = Vector2(0, 0);

    parent?.add(id);
    infos.add(id);

    // インターフェースを表示
    for (var i = 0; i < interfaces.length; i++) {
      var infoWidth = 0.0;

      final interface = interfaces[i];
      final interfaceInfo = TextComponent(
        text: interface.id,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.deepOrange,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(0, (count + 1) * 12);

      infoWidth += interfaceInfo.width + 4;

      final connectedInfo = TextComponent(
        text: interface.connectedId ?? 'null',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(infoWidth, (count + 1) * 12);

      infoWidth += connectedInfo.width + 4;

      final colorInfo = TextComponent(
        text: interface.color != null ? 'color' : '',
        textRenderer: TextPaint(
          style: TextStyle(
            color: interface.color ?? Colors.black,
            fontSize: 12,
          ),
        ),
      )..position = Vector2(infoWidth + 4, (count + 1) * 12);

      infos
        ..add(interfaceInfo)
        ..add(connectedInfo)
        ..add(colorInfo);
      parent?.add(interfaceInfo);
      parent?.add(connectedInfo);
      parent?.add(colorInfo);

      count++;
    }

    final maxPortConnectionInfo = TextComponent(
      text: 'maxPortConnection: $maxNumberPortConnection',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.deepOrange,
          fontSize: 12,
        ),
      ),
    )..position = Vector2(0, (count + 1) * 12);

    infos.add(maxPortConnectionInfo);
    parent?.add(maxPortConnectionInfo);

    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    super.onHoverLeave(info);

    infos
      ..forEach((element) {
        parent?.remove(element);
      })
      ..clear();

    return true;
  }

  bool isPortSetting(int portNumber) {
    final interface = interfaces[portNumber];

    return interface.color != null &&
        interface.defaultGatewayId != null &&
        interface.connectedId != null;
  }

  void onConnect({required int portNumber}) {
    if (selectedId == null || selectedPortNumber == null) {
      selectedId = id;
      selectedPortNumber = portNumber;

      _showSelectedDebugText(portNumber);
    } else if (selectedId != id && selectedPortNumber != null) {
      final nextNode = parent?.children
          .query<Node>()
          .firstWhereOrNull((e) => e.id == selectedId);

      if (nextNode != null) {
        onDisconnect(portNumber);
        nextNode.onDisconnect(selectedPortNumber!);

        // もし向こうのやつが PC の場合 色をPC側に合わせる
        final color = nextNode.interfaces[selectedPortNumber!].color ??
            interfaces[portNumber].color;

        // 自分ノードにあるインターフェースの接続情報を変更
        interfaces[portNumber] = interfaces[portNumber].copyWith(
          color: interfaceColorOverrideGuard ? null : color,
          connectedId: selectedId,
          defaultGatewayId: selectedId,
        );

        // 相手側ノードにあるインターフェースの接続情報を変更
        nextNode.interfaces[selectedPortNumber!] =
            nextNode.interfaces[selectedPortNumber!].copyWith(
          color: nextNode.interfaceColorOverrideGuard
              ? null
              : interfaces[portNumber].color,
          connectedId: id,
          defaultGatewayId: id,
        );

        // ケーブルで接続
        parent?.add(
          Cable(
            start: this,
            end: nextNode,
            startInterfaceId: interfaces[portNumber].id,
            endInterfaceId: nextNode.interfaces[selectedPortNumber!].id,
          ),
        );
      }

      selectedId = null;
      selectedPortNumber = null;

      _hideSelectedDebugText();
    } else {
      selectedId = null;
      selectedPortNumber = null;

      _hideSelectedDebugText();
    }
  }

  void onDisconnect(int portNumber) {
    final interface = interfaces[portNumber];

    // 接続済みの node_line を取得
    final cable = parent?.children.query<Cable>().firstWhereOrNull(
          (c) =>
              c.startInterfaceId == interface.id ||
              c.endInterfaceId == interface.id,
        );

    // node_line に接続されているインターフェースをリセット
    if (cable != null) {
      final startInterfaceId = cable.start.interfaces.indexWhere(
        (element) => element.id == cable.startInterfaceId,
      );
      final endInterfaceId = cable.end.interfaces.indexWhere(
        (element) => element.id == cable.endInterfaceId,
      );
      assert(startInterfaceId > -1, 'startInterfaceId is not found');
      assert(endInterfaceId > -1, 'endInterfaceId is not found');

      cable.start.interfaces[startInterfaceId] =
          cable.start.interfaces[startInterfaceId].reset(
        colorHold: cable.start.interfaceColorOverrideGuard,
      );
      cable.end.interfaces[endInterfaceId] =
          cable.end.interfaces[endInterfaceId].reset(
        colorHold: cable.end.interfaceColorOverrideGuard,
      );

      parent?.remove(cable);
    }
  }

  /// 選択済みというテキストを表示
  void _showSelectedDebugText(int portNumber) {
    selectedInfo = TextComponent(
      text: 'selected $id $portNumber',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    )..position = Vector2(0, 0);

    parent?.add(selectedInfo!);
  }

  void _hideSelectedDebugText() {
    if (selectedInfo != null) {
      parent?.remove(selectedInfo!);
    }
  }
}
