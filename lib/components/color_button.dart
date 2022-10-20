import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';

import 'package:flutter/material.dart';
import 'package:router_game_f/constants.dart';

class ColorButton extends PositionComponent with TapCallbacks, Hoverable {
  ColorButton({
    this.currentColor,
    this.onTap,
  });

  void Function(Color?)? onTap;

  // ホバーの管理
  bool _isColorHovering = false;

  @override
  double get width => 24;

  @override
  double get height => 24;

  @override
  int get priority => GameZIndex.interfaceInfo;

  late CircleComponent _currentComponent;

  final List<PositionComponent> _hoverInfo = [];

  Color? currentColor;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    _currentComponent = CircleComponent(
      radius: width / 2,
      paint: Paint()..color = currentColor ?? Colors.transparent,
    );

    add(_currentComponent);

    return null;
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    super.onHoverEnter(info);

    _isColorHovering = true;

    _hoverInfo
      ..add(
        _ColorSelectInterface(
          onEnter: () => _isColorHovering = true,
          onLeave: () => {_isColorHovering = false, _hideColorSelectInfo()},
        )..position = Vector2(0, height + 4),
      )
      ..addAll([
        _ColorSelectButton(
          color: Colors.red,
          onTap: () {
            onTap?.call(Colors.red);
            _currentComponent.setColor(Colors.red);
          },
        )..position = Vector2(0, height + 6),
        _ColorSelectButton(
          color: Colors.greenAccent,
          onTap: () {
            onTap?.call(Colors.greenAccent);
            _currentComponent.setColor(Colors.greenAccent);
          },
        )..position = Vector2(width + 4, height + 6),
        _ColorSelectButton(
          color: Colors.blue,
          onTap: () {
            onTap?.call(Colors.blue);
            _currentComponent.setColor(Colors.blue);
          },
        )..position = Vector2((width + 4) * 2, height + 6),
      ])
      ..map(add).toList();

    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    super.onHoverLeave(info);

    _isColorHovering = false;

    _hideColorSelectInfo();

    return true;
  }

  void _hideColorSelectInfo() {
    Future.delayed(
      GameConstants.hoverUiDuration,
      () {
        if (!_isColorHovering && _hoverInfo.isNotEmpty) {
          _hoverInfo.map(remove).toList();
          _hoverInfo.clear();
        }
      },
    );
  }
}

class _ColorSelectButton extends PositionComponent with TapCallbacks {
  _ColorSelectButton({
    required this.color,
    this.onTap,
  });

  Color color;
  void Function()? onTap;

  @override
  double get width => 24;

  @override
  double get height => 24;

  @override
  int get priority => GameZIndex.interfaceColorSelectInfo;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      CircleComponent(radius: width / 2, paint: Paint()..color = color),
    );

    return null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    onTap?.call();
  }
}

class _ColorSelectInterface extends PositionComponent with Hoverable {
  _ColorSelectInterface({
    this.onEnter,
    this.onLeave,
  });

  void Function()? onEnter;
  void Function()? onLeave;

  @override
  double get width => 100;

  @override
  double get height => 30;

  @override
  int get priority => GameZIndex.interfaceColorSelectInfo;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(width, height);
  }

  @override
  Future<void>? onLoad() {
    super.onLoad();

    add(
      RectangleComponent(
        size: Vector2(width, height),
        paint: Paint()
          ..color = const Color(0xFFC5C5C5)
          ..style = PaintingStyle.fill,
      ),
    );

    return null;
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    super.onHoverEnter(info);

    onEnter?.call();

    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    super.onHoverLeave(info);

    onLeave?.call();

    return true;
  }
}
