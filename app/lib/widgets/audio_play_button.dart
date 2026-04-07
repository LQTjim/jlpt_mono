import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';

class AudioPlayButton extends StatefulWidget {
  final int wordId;

  const AudioPlayButton({super.key, required this.wordId});

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  // Only auto-play when the user explicitly triggered a request this session.
  bool _shouldAutoPlay = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      // Only reset on completed — not on idle, which fires transiently during setUrl.
      if (state.processingState == ProcessingState.completed && _isPlaying) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  bool _isPendingAutoPlay(AudioWordState state) =>
      _shouldAutoPlay &&
      state.status == AudioStatus.ready &&
      !state.isUrlExpired &&
      !_isPlaying;

  Future<void> _playAudio(String url) async {
    setState(() => _isPlaying = true);
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _onTap(AudioProvider provider, AudioWordState state) async {
    if (state.status == AudioStatus.ready &&
        state.presignedUrl != null &&
        !state.isUrlExpired) {
      await _playAudio(state.presignedUrl!);
      return;
    }
    // idle, failed, expired URL → request a fresh one; auto-play on ready
    setState(() => _shouldAutoPlay = true);
    await provider.requestAudio(widget.wordId);
  }

  BorderRadius _getSketchBorderLight() {
    switch (widget.wordId.hashCode.abs() % 4) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(12, 16),
          topRight: Radius.elliptical(40, 6),
          bottomRight: Radius.elliptical(8, 18),
          bottomLeft: Radius.elliptical(60, 4),
        );
      case 1:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(60, 4),
          topRight: Radius.elliptical(8, 18),
          bottomRight: Radius.elliptical(40, 6),
          bottomLeft: Radius.elliptical(12, 14),
        );
      case 2:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(8, 20),
          topRight: Radius.elliptical(40, 6),
          bottomRight: Radius.elliptical(12, 16),
          bottomLeft: Radius.elliptical(60, 8),
        );
      case 3:
      default:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(40, 6),
          topRight: Radius.elliptical(12, 14),
          bottomRight: Radius.elliptical(60, 4),
          bottomLeft: Radius.elliptical(10, 20),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final state = provider.stateFor(widget.wordId);

    if (_isPendingAutoPlay(state)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isPendingAutoPlay(state)) {
          setState(() => _shouldAutoPlay = false);
          _playAudio(state.presignedUrl!);
        }
      });
    }

    final showSpinner =
        state.status == AudioStatus.loading || _isPlaying || _isPendingAutoPlay(state);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15);
    final borderRadius = _getSketchBorderLight();
    
    final iconColor = state.status == AudioStatus.failed
        ? AppColors.error
        : AppColors.terracottaMuted;

    return Tooltip(
      message: '播放發音',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: showSpinner ? null : () => _onTap(provider, state),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: borderRadius,
            ),
            child: showSpinner
                ? Center(
                    child: _SketchySpinner(color: AppColors.terracottaMuted),
                  )
                : Icon(
                    Icons.volume_up_outlined,
                    color: iconColor,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}

// Custom hand-drawn spinning loader
class _SketchySpinner extends StatefulWidget {
  final Color color;

  const _SketchySpinner({required this.color});

  @override
  State<_SketchySpinner> createState() => _SketchySpinnerState();
}

class _SketchySpinnerState extends State<_SketchySpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // A slightly uneven rotation speed fits the sketch style
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
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
        child: CustomPaint(
          size: const Size(20, 20),
          painter: _SketchySpinnerPainter(color: widget.color),
        ),
      ),
    );
  }
}

class _SketchySpinnerPainter extends CustomPainter {
  final Color color;

  _SketchySpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    final path = Path();
    const int steps = 14;
    // Draw roughly an 80% circle
    for (int i = 0; i <= steps; i++) {
        double theta = (i / steps) * (2 * pi * 0.8);
        // Add a wobbly wobble to the radius
        double wave = sin(i * 2.5) * 1.5; 
        double r = baseRadius + wave;
        
        double x = center.dx + r * cos(theta);
        double y = center.dy + r * sin(theta);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
    }
    
    // Add an extra floating dot/dash near the end to make it look messy
    double endTheta = 2 * pi * 0.95;
    path.moveTo(
      center.dx + baseRadius * cos(endTheta), 
      center.dy + baseRadius * sin(endTheta)
    );
    path.lineTo(
      center.dx + (baseRadius + 1) * cos(endTheta + 0.1), 
      center.dy + (baseRadius + 1) * sin(endTheta + 0.1)
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SketchySpinnerPainter old) => old.color != color;
}
