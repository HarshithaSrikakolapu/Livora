import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';
import 'package:Livora/features/live/presentation/widgets/youtube_web_player.dart';
import 'package:Livora/features/live/presentation/widgets/live_chat_section.dart';

import 'package:Livora/features/live/data/live_stream_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';

class LivePlayerScreen extends ConsumerStatefulWidget {
  final LiveStream stream;

  const LivePlayerScreen({super.key, required this.stream});

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen> {
  late LiveStreamService _streamService;
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  BetterPlayerController? _betterPlayerController;
  bool _isYoutube = false;
  bool _isFacebook = false;
  bool _isHls = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _streamService = ref.read(liveStreamServiceProvider);
    
    // Get user ID for unique tracking
    final authState = ref.read(firebaseAuthNotifierProvider);
    String userId = 'anonymous';
    if (authState is Authenticated) {
      userId = authState.user.id;
    } else if (authState is PendingApproval) {
      userId = authState.user.id;
    }
    
    // Track viewer joining immediately
    debugPrint('LIVE PLAYER: Calling joinStream for ${widget.stream.id} (User: $userId)');
    _streamService.joinStream(widget.stream.id, userId);
    
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      String url = widget.stream.streamUrl;
      String? extractedId = YoutubePlayer.convertUrlToId(url);
      
      // Manual fallback for /live/ URLs which standard parser often misses
      if (extractedId == null && url.contains('/live/')) {
        final RegExp regExp = RegExp(r'/live/([^/?#]+)');
        final match = regExp.firstMatch(url);
        if (match != null && match.groupCount >= 1) {
          extractedId = match.group(1);
        }
      }

      _isYoutube = widget.stream.platformType == PlatformType.youtube || (extractedId != null);
      _isFacebook = widget.stream.platformType == PlatformType.facebook || url.contains('facebook.com');
      _isHls = url.toLowerCase().contains('.m3u8');

      debugPrint('LIVE PLAYER: Initializing stream ${widget.stream.id} (URL: $url, extractedId: $extractedId, platform: ${widget.stream.platformType})');

      if (_isYoutube && extractedId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: extractedId,
          flags: const YoutubePlayerFlags(
            isLive: true,
            autoPlay: true,
          ),
        );
        if (mounted) setState(() {});
      } else if (_isFacebook) {
        // Facebook is handled in the build method via WebView
        if (mounted) setState(() {});
      } else if (_isHls) {
        BetterPlayerDataSource dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          liveStream: true,
        );
        _betterPlayerController = BetterPlayerController(
          const BetterPlayerConfiguration(
            autoPlay: true,
            looping: false,
            aspectRatio: 16 / 9,
            fit: BoxFit.contain,
          ),
          betterPlayerDataSource: dataSource,
        );
        if (mounted) setState(() {});
      } else {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.stream.streamUrl),
        );
        
        await _videoPlayerController!.initialize();
        
        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              autoPlay: true,
              isLive: true,
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              placeholder: const Center(
                child: CircularProgressIndicator(color: ColorPalette.livoraRed),
              ),
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            );
          });
        }
      }
    } catch (e) {
      debugPrint('LIVE PLAYER ERROR: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // Track viewer leaving using captured service
    debugPrint('LIVE PLAYER: Calling leaveStream for ${widget.stream.id}');
    _streamService.leaveStream(widget.stream.id);
    
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveStreamAsync = ref.watch(singleStreamProvider(widget.stream.id));
    
    // Fallback to widget.stream if live data hasn't loaded yet
    final currentStream = liveStreamAsync.when(
      data: (s) => s ?? widget.stream,
      loading: () => widget.stream,
      error: (_, __) => widget.stream,
    );

    return Scaffold(
      backgroundColor: ColorPalette.pureBlack,
      appBar: AppBar(
        title: Text(currentStream.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildPlayer(currentStream),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, box) {
                // Calculate actual player height to ensure detail container fills the rest
                final playerWidth = MediaQuery.of(context).size.width;
                final playerHeight = (playerWidth * 9 / 16).clamp(0.0, MediaQuery.of(context).size.height * 0.75);
                
                return Container(
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    minHeight: (MediaQuery.of(context).size.height - 
                      playerHeight - 
                      kToolbarHeight - 
                      MediaQuery.of(context).padding.top).clamp(0.0, double.infinity),
                  ),
                  decoration: const BoxDecoration(
                    color: ColorPalette.darkSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: ColorPalette.livoraRed,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentStream.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Platform: ${currentStream.platformType.name.toUpperCase()}',
                                  style: const TextStyle(color: ColorPalette.softGrey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ColorPalette.livoraRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ColorPalette.livoraRed.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: ColorPalette.livoraRed),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${currentStream.viewerCount} watching',
                                      style: const TextStyle(
                                        color: ColorPalette.livoraRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.visibility, size: 14, color: ColorPalette.softGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${currentStream.totalViews} watched',
                                    style: const TextStyle(
                                      color: ColorPalette.softGrey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Live Chat',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.stream.chatEnabled)
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: ColorPalette.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: LiveChatSection(streamId: widget.stream.id),
                          ),
                        )
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline, color: ColorPalette.softGrey, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  'Live Chat is disabled for this stream.',
                                  style: TextStyle(color: ColorPalette.softGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Remove Stream Button for Creator
                      if (widget.stream.status == StreamStatus.ended)
                        Builder(
                          builder: (context) {
                            final authState = ref.watch(firebaseAuthNotifierProvider);
                            if (authState is Authenticated && authState.user.id == widget.stream.creatorId) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: ColorPalette.darkSurface,
                                        title: const Text('Remove Stream', style: TextStyle(color: Colors.white)),
                                        content: const Text('Are you sure you want to remove this stream record?', style: TextStyle(color: Colors.white70)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('CANCEL'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('REMOVE', style: TextStyle(color: ColorPalette.livoraRed)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true && mounted) {
                                      await ref.read(goLiveNotifierProvider.notifier).deleteStream(widget.stream.id);
                                      if (mounted) Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                                  label: const Text('REMOVE STREAM RECORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorPalette.livoraRed.withOpacity(0.8),
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(LiveStream currentStream) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: ColorPalette.livoraRed, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not load stream',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error',
                style: const TextStyle(color: ColorPalette.softGrey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _initializePlayer();
                },
                style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.livoraRed),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentStream.status == StreamStatus.scheduled && 
        currentStream.scheduledAt != null && 
        currentStream.scheduledAt!.isAfter(DateTime.now())) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, color: ColorPalette.softGrey, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Live starting soon',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Scheduled for ${currentStream.scheduledAt!.hour}:${currentStream.scheduledAt!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: ColorPalette.softGrey),
            ),
          ],
        ),
      );
    }

    if (_isYoutube) {
      final String? videoId = YoutubePlayer.convertUrlToId(currentStream.streamUrl) ?? 
          (RegExp(r'/live/([^/?#]+)').firstMatch(currentStream.streamUrl)?.group(1));

      if (videoId != null) {
        if (kIsWeb) {
          return YoutubeWebPlayer(videoId: videoId);
        }
        
        if (_youtubeController != null) {
          return YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
          );
        }
      }
    }

    if (_isFacebook) {
      final String encodedUrl = Uri.encodeComponent(currentStream.streamUrl);
      final String embedUrl = 'https://www.facebook.com/plugins/video.php?href=$encodedUrl&show_text=false&t=0';
      
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
        ),
        onLoadError: (controller, url, code, message) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Unable to load Facebook stream: $message';
          });
        },
      );
    }

    if (_isHls && _betterPlayerController != null) {
      return BetterPlayer(controller: _betterPlayerController!);
    }
    
    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: ColorPalette.livoraRed),
            const SizedBox(height: 16),
            Text(
              'Initializing player for ${currentStream.platformType.name}...',
              style: const TextStyle(color: ColorPalette.softGrey, fontSize: 12),
            ),
          ],
        ),
      );
    }
  }
}
