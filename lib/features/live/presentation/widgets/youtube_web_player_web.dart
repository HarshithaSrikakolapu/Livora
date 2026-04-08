import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class YoutubeWebPlayer extends StatefulWidget {
  final String videoId;
  const YoutubeWebPlayer({super.key, required this.videoId});

  @override
  State<YoutubeWebPlayer> createState() => _YoutubeWebPlayerState();
}

class _YoutubeWebPlayerState extends State<YoutubeWebPlayer> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'yt-player-${widget.videoId}';
    
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/${widget.videoId}?autoplay=1&mute=0'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'autoplay; encrypted-media; picture-in-picture'
        ..allowFullscreen = true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
