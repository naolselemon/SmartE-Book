import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class AudioPlayerWidget extends StatefulWidget {
  final String localAudioPath;

  const AudioPlayerWidget({super.key, required this.localAudioPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Logger _logger = Logger();
  bool isPlaying = false;
  bool isLoading = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAudio();
    _loadAudio();
  }

  void _setupAudio() {
    _logger.i('Setting up audio player for: ${widget.localAudioPath}');
    _audioPlayer.onPositionChanged.listen((duration) {
      setState(() => currentPosition = duration);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => totalDuration = duration);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _logger.i('Audio playback completed');
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _logger.i('Player state changed: $state');
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _loadAudio() async {
    setState(() => isLoading = true);
    try {
      // Check if file exists
      final file = File(widget.localAudioPath);
      if (!await file.exists()) {
        _logger.e('Audio file not found: ${widget.localAudioPath}');
        setState(() {
          errorMessage = 'Audio file not found';
          isLoading = false;
        });
        return;
      }

      // Try .mp4, fallback to .mp3
      String audioPath = widget.localAudioPath;
      if (!audioPath.endsWith('.mp4') && !audioPath.endsWith('.mp3')) {
        final mp4Path = audioPath.replaceAll(RegExp(r'\.\w+$'), '.mp4');
        final mp3Path = audioPath.replaceAll(RegExp(r'\.\w+$'), '.mp3');
        if (await File(mp4Path).exists()) {
          audioPath = mp4Path;
        } else if (await File(mp3Path).exists()) {
          audioPath = mp3Path;
        } else {
          _logger.e('No valid audio file found: $mp4Path or $mp3Path');
          setState(() {
            errorMessage = 'No valid audio file found';
            isLoading = false;
          });
          return;
        }
      }

      _logger.i('Loading audio from: $audioPath');
      await _audioPlayer.setSource(DeviceFileSource(audioPath));
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      _logger.e('Failed to load audio: $e}');
      setState(() {
        errorMessage = 'Failed to load audio: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage!)));
      return;
    }

    try {
      if (isPlaying) {
        await _audioPlayer.pause();
        _logger.i('Audio paused');
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.localAudioPath));
        _logger.i('Audio playing: ${widget.localAudioPath}');
      }
    } catch (e) {
      _logger.e('Playback error: $e}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback error: ${e.toString()}')),
      );
      setState(() => isPlaying = false); // Reset on error
    }
  }

  void _seekToPosition(double value) async {
    try {
      final newPosition = Duration(seconds: value.toInt());
      await _audioPlayer.seek(newPosition);
      _logger.i('Seek to: $newPosition');
    } catch (e) {
      _logger.e('Seek error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Column(
        children: [
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _loadAudio, child: const Text('Retry')),
        ],
      );
    }

    return Column(
      children: [
        Slider(
          value: currentPosition.inSeconds.toDouble(),
          max:
              totalDuration.inSeconds.toDouble() > 0
                  ? totalDuration.inSeconds.toDouble()
                  : 1,
          onChanged: _seekToPosition,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}",
            ),
            Text(
              "${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString()}.padLeft(2, '0')}",
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.purple,
              ),
              onPressed: _togglePlayPause,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _logger.i('Disposing audio player');
    _audioPlayer.dispose();
    super.dispose();
  }
}
