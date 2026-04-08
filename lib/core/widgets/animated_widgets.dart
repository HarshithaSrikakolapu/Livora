import 'package:flutter/material.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/core/animations/animation_constants.dart';

// 1. Fade In Up Animation (for page sections/cards)
class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;

  const FadeInUp({
    super.key,
    required this.child,
    this.duration = AppAnimations.durationMedium,
    this.delay = Duration.zero,
    this.offset = 30.0,
  });

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveEntrance),
    );

    _translate = Tween<Offset>(begin: Offset(0, widget.offset), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveEntrance),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
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
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _translate.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// 2. Animated Scalling Button (Micro-interaction)
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

// 3. Staggered List (for lists/grids)
class StaggeredList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Duration delay;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const StaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.delay = AppAnimations.staggerDelay,
    this.scrollDirection = Axis.vertical,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      padding: padding ?? EdgeInsets.zero,
      shrinkWrap: true,
      physics: physics,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: delay * index,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

// 4. Pulsing Badge (for LIVE status)
class PulsingBadge extends StatefulWidget {
  final Widget child;
  final Color glowColor;

  const PulsingBadge({
    super.key,
    required this.child,
    this.glowColor = ColorPalette.livoraRed,
  });

  @override
  State<PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<PulsingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _opacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: widget.glowColor.withOpacity(_opacity.value),
                ),
                width: 60, 
                height: 60,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

// 5. Explicit "Live Now" Pulsing Dot
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({super.key, this.color = ColorPalette.livoraRed, this.size = 8});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _scale = Tween<double>(begin: 1.0, end: 2.5).animate(_controller);
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color.withOpacity(0.8), width: 1),
              ),
            ),
          ),
        ),
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

// 6. Scale Fade In (For Cards: Scale 0.95 -> 1.0, Opacity 0 -> 1)
class ScaleFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double initialScale;

  const ScaleFadeIn({
    super.key,
    required this.child,
    this.duration = AppAnimations.durationShort, // Cards should be snappy
    this.delay = Duration.zero,
    this.initialScale = 0.95,
  });

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scale = Tween<double>(begin: widget.initialScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveEntrance),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
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
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
