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
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _loading = true;
  bool _isInPip = false;
  Timer? _timeoutTimer;

  final Pip _pip = Pip();

  @override
  void initState() {
    super.initState();
    _enterFullScreen();
    _initializeVideo();
    _startTimeoutCheck();
    _setupPip();
  }

  void _enterFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.channel.url))
      ..initialize().then((_) {
        setState(() {
          _ready = true;
          _loading = false;
        });
        _controller.play();
        if (Platform.isAndroid || Platform.isIOS) {
          WakelockPlus.enable();
        }
      })
      ..addListener(_videoListener)
      ..setLooping(true);
  }

  void _videoListener() {
    if (Platform.isAndroid || Platform.isIOS) {
      if (_controller.value.isPlaying) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }
  }

  void _startTimeoutCheck() {
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_ready) {
        Fluttertoast.showToast(
          msg: "Channel cannot be reached or is offline.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  Future<void> _refreshVideo() async {
    setState(() {
      _ready = false;
      _loading = true;
    });
    await _controller.pause();
    await _controller.dispose();
    _initializeVideo();
    _startTimeoutCheck();
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

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller.removeListener(_videoListener);
    if (Platform.isAndroid || Platform.isIOS) {
      WakelockPlus.disable();
    }
    _pip.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            _refreshVideo();
          }
        },
        child: Stack(
          children: [
            if (_ready)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
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
              ),
            if (!_ready || _loading)
              Positioned.fill(
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (_ready && !_controller.value.isPlaying && !_loading)
              const Center(
                child: Icon(Icons.play_arrow, size: 80, color: Colors.white70),
              ),

            if (_ready && !_isInPip)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.black54,
                  onPressed: enterPip,
                  child: const Icon(Icons.picture_in_picture_alt),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
