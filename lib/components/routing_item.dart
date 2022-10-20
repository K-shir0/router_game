import 'dart:ui';

import 'package:equatable/equatable.dart';

class RoutingItem extends Equatable {
  const RoutingItem({
    required this.color,
    required this.outputInterfaceNumber,
  });

  final Color color;
  final int outputInterfaceNumber;

  @override
  List<Object?> get props => [color, outputInterfaceNumber];
}
