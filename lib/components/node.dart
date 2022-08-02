import 'package:flame/components.dart';

import 'package:router_game_f/components/components.dart';

class Node extends PositionComponent {
  Node({required this.id});

  /// 識別するためのID
  final String id;

  /// 処理するパケットを保存しておく場所
  final List<Packet> packets = [];

  /// 送られたパケットを保存しておくバッファ
  final List<Packet> buffer = [];
}
