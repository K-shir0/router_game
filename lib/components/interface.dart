import 'dart:ui';

import 'package:equatable/equatable.dart';

class Interface extends Equatable {
  const Interface({
    required this.id,
    required this.color,
    required this.connectedId,
    required this.defaultGatewayId,
  });

  final String id;
  final Color? color;
  final String? connectedId;
  final String? defaultGatewayId;

  @override
  List<Object?> get props => [
        id,
        color,
        connectedId,
        defaultGatewayId,
      ];

  @override
  String toString() {
    return 'Interface('
        'id: $id, '
        'color: $color, '
        'connectedId: $connectedId, '
        'defaultGatewayId: $defaultGatewayId'
        ')';
  }

  Interface reset({bool colorHold = false}) {
    return Interface(
      id: id,
      color: colorHold ? color : null,
      connectedId: null,
      defaultGatewayId: null,
    );
  }

  Interface copyWith({
    String? id,
    Color? color,
    String? connectedId,
    String? defaultGatewayId,
  }) {
    return Interface(
      id: id ?? this.id,
      color: color ?? this.color,
      connectedId: connectedId ?? this.connectedId,
      defaultGatewayId: defaultGatewayId ?? this.defaultGatewayId,
    );
  }
}
