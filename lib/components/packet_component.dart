import 'package:flame/components.dart';

import 'package:router_game_f/components/packet_data.dart';
import 'package:router_game_f/components/packet_view.dart';

class PacketComponent extends PositionComponent {
  PacketComponent({
    required this.data,
    required this.from,
    required this.to,
    required this.onComplete,
  }) {
    _distance = to - from;
  }

  final PacketData data;
  final Vector2 from;
  final Vector2 to;

  void Function() onComplete;
  late final Vector2 _distance;

  @override
  double get width => 24;

  @override
  double get height => 24;

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      PacketView(data: data)
        ..size = Vector2(width, height)
        ..position = (from - (Vector2(width, height) / 2)),
    );

    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // to から from に移動
    const moveSpeed = 1.0;
    final move = _distance.normalized() * moveSpeed;
    position += move;

    // to に到着すると止まる
    if ((position + from).distanceTo(to) < 1) {
      // 到着処理
      onComplete();
      parent?.remove(this);
    }
  }
}
