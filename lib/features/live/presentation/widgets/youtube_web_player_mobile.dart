import 'package:flutter/material.dart';

class YoutubeWebPlayer extends StatelessWidget {
  final String videoId;
  const YoutubeWebPlayer({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
