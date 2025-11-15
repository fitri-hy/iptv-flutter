import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pip/pip.dart';
import '../models/channel.dart';
import '../services/m3u_service.dart';
import '../services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/channel_card.dart';

class PlayerScreen extends StatefulWidget {
  final String channelId;
  const PlayerScreen({super.key, required this.channelId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _loading = true;
  bool _isInPip = false;
  bool _error = false;

  bool _showOverlay = true;
  bool _isDragging = false;

  Timer? _overlayTimer;
  final Pip _pip = Pip();
  Channel? _currentChannel;
  List<Channel> _recommendedChannels = [];
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _forceLandscape();
    _loadChannelById(widget.channelId);
    _setupPip();
    _loadFavorites();
  }

  void _forceLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _loadChannelById(String id) async {
    final channels = await M3UService.fetchPlaylist(AppConstants.playlistUrl);
    final ch = channels.firstWhere((c) => c.url == id, orElse: () => channels.first);
    setState(() => _currentChannel = ch);
    await _initializeVideo();
    _loadRecommendedChannels(ch);
  }

  Future<void> _initializeVideo() async {
    if (_currentChannel == null) return;
    setState(() {
      _loading = true;
      _error = false;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(_currentChannel!.url));

    try {
      await _controller.initialize();
      setState(() {
        _ready = true;
        _loading = false;
      });
      _controller
        ..play()
        ..setLooping(true)
        ..addListener(_videoListener);

      if (Platform.isAndroid || Platform.isIOS) await WakelockPlus.enable();
      _startOverlayTimer();
    } catch (e) {
      _handleError("Cannot load channel");
    }
  }

  void _videoListener() {
    if (!mounted) return;
    if (_controller.value.hasError && !_error) _handleError("Channel cannot be reached or is offline.");
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = true;
      _ready = false;
    });
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDragging) setState(() => _showOverlay = false);
    });
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
    if (_showOverlay) _startOverlayTimer();
  }

  Future<void> _refreshVideo() async {
    await _controller.pause();
    await _controller.dispose();
    await _initializeVideo();
  }

  Future<void> _setupPip() async {
    final options = PipOptions(autoEnterEnabled: false, aspectRatioX: 16, aspectRatioY: 9, controlStyle: 0);
    await _pip.setup(options);
    await _pip.registerStateChangedObserver(PipStateChangedObserver(onPipStateChanged: (state, error) {
      if (!mounted) return;
      setState(() => _isInPip = state == PipState.pipStateStarted);
    }));
  }

  Future<void> enterPip() async {
    if (await _pip.isSupported() && !_isInPip) await _pip.start();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _favoriteIds = prefs.getStringList('favorites') ?? []);
  }

  Future<void> _toggleFavorite(Channel ch) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(ch.url)) _favoriteIds.remove(ch.url);
      else _favoriteIds.add(ch.url);
      prefs.setStringList('favorites', _favoriteIds);
    });
  }

  void _loadRecommendedChannels(Channel current) async {
    final channels = await M3UService.fetchPlaylist(AppConstants.playlistUrl);
    setState(() {
      _recommendedChannels = channels
          .where((ch) => ch.country == current.country && ch.url != current.url)
          .toList();
    });
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    if (_controller.value.isInitialized) _controller.removeListener(_videoListener);
    _controller.dispose();
    if (Platform.isAndroid || Platform.isIOS) WakelockPlus.disable();
    _pip.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentChannel == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleOverlay,
        onPanStart: (_) {
          _isDragging = true;
          _overlayTimer?.cancel();
        },
        onPanUpdate: (_) => _startOverlayTimer(),
        onPanEnd: (_) {
          _isDragging = false;
          _startOverlayTimer();
        },
        child: Stack(
          children: [
            if (_ready)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            if (_loading) const Center(child: CircularProgressIndicator(color: Colors.white)),
            if (_error)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                    SizedBox(height: 10),
                    Text("Failed to load channel", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            AnimatedOpacity(
              opacity: _showOverlay ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(_currentChannel!.name,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _refreshVideo),
                              IconButton(
                                icon: Icon(
                                  _favoriteIds.contains(_currentChannel!.url) ? Icons.favorite : Icons.favorite_border,
                                  color: _favoriteIds.contains(_currentChannel!.url) ? Colors.redAccent : Colors.white,
                                ),
                                onPressed: () => _toggleFavorite(_currentChannel!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_controller.value.isPlaying) _controller.pause();
                          else _controller.play();
                          _startOverlayTimer();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_recommendedChannels.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _recommendedChannels.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final ch = _recommendedChannels[index];
                          final isFav = _favoriteIds.contains(ch.url);
                          return SizedBox(
                            width: 150,
                            child: ChannelCard(
                              channel: ch,
                              isFavorite: isFav,
                              borderRadius: 3,
                              onFavoriteToggle: () => _toggleFavorite(ch),
                              onTap: () {
                                setState(() => _currentChannel = ch);
                                _refreshVideo();
                                _loadRecommendedChannels(ch);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (_ready && !_isInPip)
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showOverlay ? 1 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
                    onPressed: enterPip,
                    child: const Icon(Icons.picture_in_picture_alt_rounded),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
