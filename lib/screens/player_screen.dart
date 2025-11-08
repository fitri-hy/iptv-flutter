import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pip/pip.dart';
import '../models/channel.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  final bool isFavorite;

  const PlayerScreen({
    super.key,
    required this.channel,
    this.isFavorite = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _loading = true;
  bool _isInPip = false;
  bool _error = false;
  bool _showHeader = true;
  Timer? _timeoutTimer;
  Timer? _hideHeaderTimer;

  final Pip _pip = Pip();

  @override
  void initState() {
    super.initState();
    _enterFullScreen();
    _initializeVideo();
    _setupPip();
    _scheduleHideHeader();
  }

  void _enterFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.channel.url));

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

      if (Platform.isAndroid || Platform.isIOS) {
        await WakelockPlus.enable();
      }

      _startTimeoutCheck();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _videoListener() {
    if (!mounted) return;
    if (Platform.isAndroid || Platform.isIOS) {
      if (_controller.value.isPlaying) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }

    if (_controller.value.hasError && !_error) {
      _handleError("Channel cannot be reached or is offline.");
    }
  }

  void _startTimeoutCheck() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_ready && !_error) {
        _handleError("Channel cannot be reached or is offline.");
      }
    });
  }

  void _handleError(String message) {
  if (!mounted) return;
  setState(() {
    _loading = false;
    _error = true;
    _ready = false;
  });
    Fluttertoast.showToast(
      msg: "Channel cannot be reached or is offline.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _refreshVideo() async {
    await _controller.pause();
    await _controller.dispose();
    await _initializeVideo();
  }

  Future<void> _setupPip() async {
    final options = PipOptions(
      autoEnterEnabled: false,
      aspectRatioX: 16,
      aspectRatioY: 9,
      controlStyle: 0,
    );

    await _pip.setup(options);
    await _pip.registerStateChangedObserver(
      PipStateChangedObserver(onPipStateChanged: (state, error) {
        if (!mounted) return;
        setState(() {
          _isInPip = state == PipState.pipStateStarted;
        });
      }),
    );
  }

  Future<void> enterPip() async {
    if (await _pip.isSupported() && !_isInPip) {
      await _pip.start();
    }
  }


  void _toggleHeaderVisibility() {
    setState(() => _showHeader = !_showHeader);
    if (_showHeader) _scheduleHideHeader();
  }

  void _scheduleHideHeader() {
    _hideHeaderTimer?.cancel();
    _hideHeaderTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHeader = false);
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _hideHeaderTimer?.cancel();
    if (_controller.value.isInitialized) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      WakelockPlus.disable();
    }
    _pip.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.channel;
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleHeaderVisibility,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            _refreshVideo();
          }
        },
        child: Stack(
          children: [

            if (_ready)
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),


            if (_loading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),


			if (_error)
			  Center(
				child: Column(
				  mainAxisAlignment: MainAxisAlignment.center,
				  children: [
					const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
					const SizedBox(height: 10),
					const Text(
					  "Failed to load video",
					  style: TextStyle(color: Colors.white70, fontSize: 16),
					),
					const SizedBox(height: 12),
					Row(
					  mainAxisAlignment: MainAxisAlignment.center,
					  children: [
						ElevatedButton.icon(
						  style: ElevatedButton.styleFrom(
							backgroundColor: Colors.white10,
							foregroundColor: Colors.white,
							shape: RoundedRectangleBorder(
							  borderRadius: BorderRadius.circular(3),
							),
						  ),
						  onPressed: () => Navigator.pop(context),
						  icon: const Icon(Icons.arrow_back),
						  label: const Text("Back"),
						),
						const SizedBox(width: 12),
						ElevatedButton.icon(
						  style: ElevatedButton.styleFrom(
							backgroundColor: Colors.white10,
							foregroundColor: Colors.white,
							shape: RoundedRectangleBorder(
							  borderRadius: BorderRadius.circular(3),
							),
						  ),
						  onPressed: _refreshVideo,
						  icon: const Icon(Icons.refresh),
						  label: const Text("Retry"),
						),
					  ],
					),
				  ],
				),
			),

            AnimatedOpacity(
              opacity: _showHeader ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          channel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshVideo,
                      ),
                    ],
                  ),
                ),
              ),
            ),


            if (_ready && !_isInPip)
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showHeader ? 1 : 0.7,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: enterPip,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
