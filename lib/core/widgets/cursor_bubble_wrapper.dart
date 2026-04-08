import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:Livora/core/theme/color_palette.dart';

class CursorBubbleWrapper extends StatefulWidget {
  final Widget child;

  const CursorBubbleWrapper({super.key, required this.child});

  @override
  State<CursorBubbleWrapper> createState() => _CursorBubbleWrapperState();
}

class _CursorBubbleWrapperState extends State<CursorBubbleWrapper> with SingleTickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  late Ticker _ticker;
  Offset _lastCursorPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_updateBubbles)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateBubbles(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      final now = DateTime.now();
      _bubbles.removeWhere((b) => now.difference(b.startTime) > b.duration);
      for (var b in _bubbles) {
        b.update();
      }
    });
  }

  void _onPointerMove(PointerEvent event) {
    final dist = (event.position - _lastCursorPos).distance;
    if (dist > 15) { // Throttle bubble creation
      _lastCursorPos = event.position;
      _spawnBubble(event.position);
    }
  }

  void _spawnBubble(Offset position) {
    final random = Random();
    final bubble = _Bubble(
      position: position,
      startTime: DateTime.now(),
      duration: Duration(milliseconds: 800 + random.nextInt(400)),
      size: 4 + random.nextDouble() * 8,
      velocity: Offset(
        (random.nextDouble() - 0.5) * 2,
        (random.nextDouble() - 0.5) * 2,
      ),
    );
    _bubbles.add(bubble);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onPointerMove,
      child: Stack(
        children: [
          widget.child,
          RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _BubblePainter(_bubbles),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble {
  Offset position;
  final DateTime startTime;
  final Duration duration;
  final double size;
  final Offset velocity;

  _Bubble({
    required this.position,
    required this.startTime,
    required this.duration,
    required this.size,
    required this.velocity,
  });

  void update() {
    position += velocity;
  }
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;

  _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    for (var bubble in bubbles) {
      final age = now.difference(bubble.startTime).inMilliseconds / bubble.duration.inMilliseconds;
      if (age >= 1.0) continue;

      final opacity = (1.0 - age) * 0.4;
      final paint = Paint()
        ..color = ColorPalette.livoraRed.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(bubble.position, bubble.size * (1.0 + age * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
