import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.inkLight : AppColors.inkDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.appTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 4.0,
                color: textColor,
              ),
            ),
            const SizedBox(height: 48),
            const _SketchySpinner(),
          ],
        ),
      ),
    );
  }
}

// Custom hand-drawn spinning loader for full-screen sizing
class _SketchySpinner extends StatefulWidget {
  static const double _size = 48;

  const _SketchySpinner();

  @override
  State<_SketchySpinner> createState() => _SketchySpinnerState();
}

class _SketchySpinnerState extends State<_SketchySpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // A slightly slow, uneven rotation speed fits the sketch style
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Transform.rotate(
        angle: _ctrl.value * 2 * pi,
        child: const CustomPaint(
          size: Size(_SketchySpinner._size, _SketchySpinner._size),
          painter: _SketchySpinnerPainter(color: AppColors.terracottaMuted),
        ),
      ),
    );
  }
}

class _SketchySpinnerPainter extends CustomPainter {
  final Color color;

  // Cached path — geometry is fixed, only color ever changes.
  static Path? _cachedPath;
  static Size? _cachedSize;

  const _SketchySpinnerPainter({required this.color});

  static Path _buildPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;
    final path = Path();
    const int steps = 20;

    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * (2 * pi * 0.85);
      final wave = sin(i * 3.0) * 2.0;
      final r = baseRadius + wave;
      final x = center.dx + r * cos(theta);
      final y = center.dy + r * sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final endTheta = 2 * pi * 0.95;
    path.moveTo(center.dx + baseRadius * cos(endTheta), center.dy + baseRadius * sin(endTheta));
    path.lineTo(center.dx + (baseRadius + 1) * cos(endTheta + 0.1), center.dy + (baseRadius + 1) * sin(endTheta + 0.1));

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedSize != size) {
      _cachedPath = _buildPath(size);
      _cachedSize = size;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(_cachedPath!, paint);
  }

  @override
  bool shouldRepaint(covariant _SketchySpinnerPainter old) => old.color != color;
}
