import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

enum Shape {
  square,
  circle,
}

class Packet extends Equatable {
  const Packet({
    required this.color,
    required this.shape,
    this.dt,
  });

  final Color color;
  final Shape shape;
  final double? dt;

  @override
  List<Object?> get props => [color, shape, dt];

  Packet copyWith({
    Color? color,
    Shape? shape,
    double? dt,
  }) {
    return Packet(
      color: color ?? this.color,
      shape: shape ?? this.shape,
      dt: dt ?? this.dt,
    );
  }
}
