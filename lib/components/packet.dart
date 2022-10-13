import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

enum PacketShape { square, circle, triangle }

class Packet extends Equatable {
  const Packet({
    required this.color,
    required this.shape,
    // TODO(k-shir0): 空はまずいかも（未検証）
    this.sourceId = '',
  });

  final Color color;
  final PacketShape shape;
  final String sourceId;

  @override
  List<Object?> get props => [color, shape, sourceId];

  Packet copyWith({
    Color? color,
    PacketShape? shape,
    String? sourceId,
  }) {
    return Packet(
      color: color ?? this.color,
      shape: shape ?? this.shape,
      sourceId: sourceId ?? this.sourceId,
    );
  }
}
