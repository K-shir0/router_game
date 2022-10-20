import 'dart:ui';

class GameColors {
  GameColors._();

  static const Color backgroundColor = Color(0x00F2F2F2);
}

class GameConstants {
  static const Duration hoverUiDuration = Duration(milliseconds: 75);
}

class GameZIndex {
  GameZIndex._();

  static const int packet = -1;
  static const int node = 0;
  static const int interfaceInfo = 1;
  static const int interfaceColorSelectInfo = 2;
}
