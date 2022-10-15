import 'package:flame/components.dart';

import 'package:flutter/material.dart';

import 'package:router_game_f/components/components.dart';

class Cable extends PositionComponent {
  Cable({
    required this.start,
    required this.end,
    this.startInterfaceId,
    this.endInterfaceId,
  });

  final Node start;
  final Node end;

  final String? startInterfaceId;
  final String? endInterfaceId;

  @override
  int get priority => -1;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      start.toRect().center,
      end.toRect().center,
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 12,
    );
  }
}
