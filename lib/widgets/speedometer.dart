import 'dart:math';
import 'package:flutter/material.dart';

class PomaSpeedometer extends StatefulWidget {
  final int score;
  final int maxScore;

  const PomaSpeedometer({
    super.key,
    required this.score,
    this.maxScore = 26,
  });

  @override
  State<PomaSpeedometer> createState() => _PomaSpeedometerState();
}

class _PomaSpeedometerState extends State<PomaSpeedometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _oldScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: widget.score.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PomaSpeedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != _oldScore) {
      _animation = Tween<double>(
        begin: _oldScore.toDouble(),
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
      _oldScore = widget.score;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(double value) {
    if (value >= 25) return Colors.green;
    if (value >= 19) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        double progress = (_animation.value / widget.maxScore).clamp(0.0, 1.0);
        Color color = _getColor(_animation.value);

        return CustomPaint(
          painter: _SpeedometerPainter(progress, color),
          child: SizedBox(
            width: 200,
            height: 100,
            child: Center(
              child: Text(
                _animation.value.toInt().toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpeedometerPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = pi; // 180 degrees
    const sweepAngle = pi; // Semicircle
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw full background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw animated progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
