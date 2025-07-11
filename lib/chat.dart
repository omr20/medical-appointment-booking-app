import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AssetVideoScreen extends StatefulWidget {
  @override
  _AssetVideoScreenState createState() => _AssetVideoScreenState();
}

class _AssetVideoScreenState extends State<AssetVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video/veedoo.mp4")
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play(); // للتشغيل التلقائي
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تشغيل فيديو من Assets")),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      )
          : null,
    );
  }
}
