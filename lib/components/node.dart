import 'package:collection/collection.dart';

import 'package:flame/components.dart';

import 'package:router_game_f/components/components.dart';
import 'package:router_game_f/components/interface.dart';
import 'package:router_game_f/node_to_node_connect.dart';

class Node extends PositionComponent {
  Node({
    required this.id,
    required this.interfaces,
    required this.maxNumberPortConnection,
  });

  /// 識別するためのID
  final String id;

  ///　ノードが持つインターフェース
  final List<Interface> interfaces;

  /// 送られたパケットを保存しておくバッファ
  final List<Packet> buffer = [];

  /// ポートの最大接続数
  final int maxNumberPortConnection;

  @override
  Future<void>? onLoad() {
    super.onLoad();

    interfaces.addAll([
      for (int i = 0; i < maxNumberPortConnection - interfaces.length; i++)
        Interface(
          color: null,
          connectedId: null,
          defaultGatewayId: null,
        )
    ]);

    return null;
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
    } else if (selectedId != id && selectedPortNumber != null) {
      final nextNode = parent?.children
          .query<Node>()
          .firstWhereOrNull((e) => e.id == selectedId);

      if (nextNode != null) {
        // もし向こうのやつが PC の場合 色をPC側に合わせる
        final color = nextNode.interfaces[selectedPortNumber!].color ??
            interfaces[portNumber].color;

        interfaces[portNumber] = Interface(
          color: color,
          connectedId: selectedId,
          defaultGatewayId: selectedId,
        );

        // TODO(k-shir0): ! を修正する
        nextNode.interfaces[selectedPortNumber!] = Interface(
          color: interfaces[portNumber].color,
          connectedId: id,
          defaultGatewayId: id,
        );
      }

      selectedId = null;
      selectedPortNumber = null;
    } else {
      selectedId = null;
      selectedPortNumber = null;
    }
  }
}
