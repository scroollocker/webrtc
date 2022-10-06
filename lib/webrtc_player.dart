import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_tutorial/signaling.dart';
import 'package:webrtc_tutorial/webrtc_controller.dart';

class WebrtcPlayer extends StatefulWidget {
  final String url;
  final WebrtcController controller;

  WebrtcPlayer({Key? key, required this.url, required this.controller})
      : super(key: key);

  @override
  State<WebrtcPlayer> createState() => _WebrtcPlayerState();
}

class _WebrtcPlayerState extends State<WebrtcPlayer> {
  late Signaling _signaling;
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  void _connect() {
    _signaling.connect();
  }

  void _disconnect() {
    _signaling.disconnect();
  }

  Future<void> _init() async {
    await _remoteRenderer.initialize();
    _signaling = Signaling(widget.url, (stream) {
      if (!mounted) return;
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    });
    widget.controller.onInitCallback?.call();
  }

  @override
  void initState() {
    _init();
    widget.controller.connect = _connect;
    widget.controller.disconnect = _disconnect;

    super.initState();
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(_remoteRenderer);
  }
}
