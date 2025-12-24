import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/values/app_colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.url);

      if (videoId == null) {
        setState(() => _isError = true);
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
        ),
      );
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return _buildErrorState();
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primaryLight,
          ),
          onReady: () {
            print('Video player ready');
          },
          onEnded: (metaData) {
            print('Video ended');
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Video',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check the video URL',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isError = false;
                  _initializePlayer();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
