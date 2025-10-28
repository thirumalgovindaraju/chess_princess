import 'package:flutter/material.dart';
import '../models/position.dart';
import '../services/animation_service.dart';

class AnimatedPiece extends StatefulWidget {
  final String symbol;
  final Position? fromPosition;
  final Position? toPosition;
  final bool isCapture;
  final VoidCallback? onAnimationComplete;

  const AnimatedPiece({
    Key? key,
    required this.symbol,
    this.fromPosition,
    this.toPosition,
    this.isCapture = false,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedPiece> createState() => _AnimatedPieceState();
}

class _AnimatedPieceState extends State<AnimatedPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final animService = AnimationService();

    _controller = AnimationController(
      duration: widget.isCapture
          ? animService.captureDuration
          : animService.moveDuration,
      vsync: this,
    );

    if (widget.isCapture) {
      _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
    } else {
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
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
      animation: _animation,
      builder: (context, child) {
        if (widget.isCapture) {
          return Transform.scale(
            scale: _animation.value,
            child: Opacity(
              opacity: _animation.value,
              child: child,
            ),
          );
        }
        return child!;
      },
      child: Text(
        widget.symbol,
        style: const TextStyle(fontSize: 40),
      ),
    );
  }
}