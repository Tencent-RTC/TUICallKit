import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index) {
    const double size = 10;
    final double opacity = ((1.0 - ((_controller.value - 0.33 * index) % 1.0)) * 10 + 5) / 20;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Transform.scale(
        scale: size / 20,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
