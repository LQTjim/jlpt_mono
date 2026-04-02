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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final state = provider.stateFor(widget.wordId);

    if (_isPendingAutoPlay(state)) {
      // Closes the one-frame gap between provider reaching `ready` and
      // _playAudio setting _isPlaying=true.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isPendingAutoPlay(state)) {
          setState(() => _shouldAutoPlay = false);
          _playAudio(state.presignedUrl!);
        }
      });
    }

    final showSpinner =
        state.status == AudioStatus.loading || _isPlaying || _isPendingAutoPlay(state);

    if (showSpinner) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.terracotta,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => _onTap(provider, state),
      icon: Icon(Icons.volume_up_outlined,
          color: state.status == AudioStatus.failed
              ? AppColors.error
              : AppColors.terracotta,
          size: 28),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: '播放發音',
    );
  }
}
