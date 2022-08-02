import 'package:flame/components.dart';

import 'package:router_game_f/components/components.dart';

class Node extends PositionComponent {
  Node({required this.id});

  /// 識別するためのID
  final String id;

  /// 送られたパケットを保存しておくバッファ
  final List<Packet> buffer = [];
}
