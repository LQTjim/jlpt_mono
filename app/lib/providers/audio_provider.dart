import 'package:flutter/foundation.dart';

import '../models/audio_response.dart';
import '../services/audio_service.dart';

enum AudioStatus { idle, loading, ready, failed }

class AudioWordState {
  final AudioStatus status;
  final String? presignedUrl;
  final DateTime? expiresAt;
  final int? jobId;

  const AudioWordState({
    required this.status,
    this.presignedUrl,
    this.expiresAt,
    this.jobId,
  });

  /// True when the URL is missing, has no expiry info, or has already expired.
  bool get isUrlExpired =>
      presignedUrl == null ||
      expiresAt == null ||
      DateTime.now().toUtc().isAfter(expiresAt!);

  static const idle = AudioWordState(status: AudioStatus.idle);
}

class AudioProvider extends ChangeNotifier {
  final AudioService _service;
  final Map<int, AudioWordState> _states;

  AudioProvider(this._service, {Map<int, AudioWordState>? initialStates})
      : _states = Map.of(initialStates ?? {});

  AudioWordState stateFor(int wordId) => _states[wordId] ?? AudioWordState.idle;

  Future<void> requestAudio(int wordId) async {
    final current = stateFor(wordId);
    if (current.status == AudioStatus.loading) return;
    if (current.status == AudioStatus.ready && !current.isUrlExpired) return;

    _setState(wordId, const AudioWordState(status: AudioStatus.loading));

    try {
      final response = await _service.requestAudio(wordId);
      await _handleResponse(wordId, response);
    } catch (_) {
      _setState(wordId, const AudioWordState(status: AudioStatus.failed));
    }
  }

  Future<void> _handleResponse(int wordId, AudioResponse response) async {
    if (response.status == 'READY' && response.presignedUrl != null) {
      _setState(wordId, AudioWordState(
        status: AudioStatus.ready,
        presignedUrl: response.presignedUrl,
        expiresAt: response.expiresAt,
        jobId: response.jobId,
      ));
      return;
    }

    if (response.status == 'FAILED') {
      _setState(wordId, AudioWordState(
        status: AudioStatus.failed,
        jobId: response.jobId,
      ));
      return;
    }

    // PENDING or PROCESSING — begin polling
    final jobId = response.jobId;
    if (jobId == null) {
      _setState(wordId, const AudioWordState(status: AudioStatus.failed));
      return;
    }

    _setState(wordId, AudioWordState(status: AudioStatus.loading, jobId: jobId));
    await _poll(wordId, jobId);
  }

  Future<void> _poll(int wordId, int jobId, {int attempt = 0}) async {
    const maxAttempts = 10;

    if (attempt >= maxAttempts) {
      _setState(wordId, AudioWordState(status: AudioStatus.failed, jobId: jobId));
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    // Bail out if state was reset while waiting (e.g. user navigated away)
    if (_states[wordId]?.jobId != jobId) return;

    try {
      final response = await _service.getStatus(jobId);
      if (response.status == 'READY' && response.presignedUrl != null) {
        _setState(wordId, AudioWordState(
          status: AudioStatus.ready,
          presignedUrl: response.presignedUrl,
          expiresAt: response.expiresAt,
          jobId: jobId,
        ));
      } else if (response.status == 'FAILED') {
        _setState(wordId, AudioWordState(status: AudioStatus.failed, jobId: jobId));
      } else {
        await _poll(wordId, jobId, attempt: attempt + 1);
      }
    } catch (_) {
      _setState(wordId, AudioWordState(status: AudioStatus.failed, jobId: jobId));
    }
  }

  void reset(int wordId) {
    _states.remove(wordId);
    notifyListeners();
  }

  void _setState(int wordId, AudioWordState state) {
    _states[wordId] = state;
    notifyListeners();
  }
}
