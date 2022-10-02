import 'dart:ui';

class Interface {
  Interface({
    required this.color,
    required this.connectedId,
    required this.defaultGatewayId,
  });

  final Color? color;
  final String? connectedId;
  final String? defaultGatewayId;

  @override
  String toString() {
    return 'Interface('
        'color: $color, '
        'connectedId: $connectedId, '
        'defaultGatewayId: $defaultGatewayId'
        ')';
  }
}
