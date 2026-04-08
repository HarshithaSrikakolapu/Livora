import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundPaths extends StatelessWidget {
  final String? title;
  final Widget? child;
  const BackgroundPaths({super.key, this.title, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingPaths(position: 1)),
          const Positioned.fill(child: FloatingPaths(position: -1)),
          if (child != null) 
            child!
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedTitle(title: title ?? "Background Paths"),
                  const SizedBox(height: 32),
                  const PremiumButton(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FloatingPaths extends StatefulWidget {
  final double position;
  const FloatingPaths({super.key, required this.position});

  @override
  State<FloatingPaths> createState() => _FloatingPathsState();
}

class _FloatingPathsState extends State<FloatingPaths> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final int _pathCount = 36;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_pathCount, (i) {
      final duration = 30 + math.Random().nextDouble() * 30; // Longer duration for smoothness
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: duration.toInt()),
      )..repeat();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(_pathCount, (i) {
            return AnimatedBuilder(
              animation: _controllers[i],
              builder: (context, child) {
                return CustomPaint(
                  painter: PathPainter(
                    index: i,
                    position: widget.position,
                    progress: _controllers[i].value,
                    color: Color.lerp(
                      Colors.white, 
                      Theme.of(context).primaryColor, 
                      i / (_pathCount - 1),
                    )!.withOpacity(0.05 + i * 0.01),
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            );
          }),
        );
      },
    );
  }
}

class PathPainter extends CustomPainter {
  final int index;
  final double position;
  final double progress;
  final Color color;

  PathPainter({
    required this.index,
    required this.position,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 + index * 0.03;

    // Scale the paths to fit the container
    final double scaleX = size.width / 696;
    final double scaleY = size.height / 316;

    final double i = index.toDouble();
    final double x1 = -(380 - i * 5 * position) * scaleX;
    final double y1 = -(189 + i * 6) * scaleY;

    final double cx1 = x1;
    final double cy1 = y1;
    final double cx2 = -(312 - i * 5 * position) * scaleX;
    final double cy2 = (216 - i * 6) * scaleY;
    final double ex1 = (152 - i * 5 * position) * scaleX;
    final double ey1 = (343 - i * 6) * scaleY;

    final double cx3 = (616 - i * 5 * position) * scaleX;
    final double cy3 = (470 - i * 6) * scaleY;
    final double cx4 = (684 - i * 5 * position) * scaleX;
    final double cy4 = (875 - i * 6) * scaleY;
    final double ex2 = cx4;
    final double ey2 = cy4;

    final Path path = Path();
    path.moveTo(x1, y1);
    path.cubicTo(cx1, cy1, cx2, cy2, ex1, ey1);
    path.cubicTo(cx3, cy3, cx4, cy4, ex2, ey2);

    // Softer path variations
    final double pathLength = 0.4 + (0.2 * math.sin(progress * math.pi * 2)); 
    final double offset = progress;

    canvas.drawPath(extractSection(path, offset, offset + pathLength), paint);
  }

  Path extractSection(Path path, double start, double end) {
    final Path segmentPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      final double totalLength = metric.length;
      final double s = totalLength * (start % 1.0);
      final double e = totalLength * (end % 1.0);
      
      if (s < e) {
        segmentPath.addPath(metric.extractPath(s, e), Offset.zero);
      } else {
        segmentPath.addPath(metric.extractPath(s, totalLength), Offset.zero);
        segmentPath.addPath(metric.extractPath(0, e), Offset.zero);
      }
    }
    return segmentPath;
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class AnimatedTitle extends StatelessWidget {
  final String title;
  const AnimatedTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final words = title.split(" ");
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(words.length, (wordIndex) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(words[wordIndex].length, (letterIndex) {
              return LetterAnimation(
                letter: words[wordIndex][letterIndex],
                delay: Duration(milliseconds: (wordIndex * 100 + letterIndex * 30).toInt()),
              );
            }),
            if (wordIndex < words.length - 1) const SizedBox(width: 12),
          ],
        );
      }),
    );
  }
}

class LetterAnimation extends StatefulWidget {
  final String letter;
  final Duration delay;
  const LetterAnimation({super.key, required this.letter, required this.delay});

  @override
  State<LetterAnimation> createState() => _LetterAnimationState();
}

class _LetterAnimationState extends State<LetterAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _yAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _yAnimation.value),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return (Theme.of(context).brightness == Brightness.dark
                        ? const LinearGradient(colors: [Colors.white, Colors.white70])
                        : const LinearGradient(colors: [Color(0xFF171717), Color(0xCC171717)]))
                    .createShader(bounds);
              },
              child: Text(
                widget.letter,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PremiumButton extends StatefulWidget {
  const PremiumButton({super.key});

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.white.withOpacity(0.1), Colors.black.withOpacity(0.1)]
                : [Colors.black.withOpacity(0.1), Colors.white.withOpacity(0.1)],
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(19),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Discover Excellence",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
