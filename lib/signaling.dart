import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_tutorial/web_socket.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  WebSocketWorker? _socketWorker;
  RTCPeerConnection? _peerConnection;
  MediaStream? _remoteStream;
  StreamStateCallback? _onAddRemoteStream;

  int? _sessionId;
  int? _peerId;
  String _url;

  Signaling(this._url, this._onAddRemoteStream);

  void registerPeerConnectionListeners() {
    _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('ICE connection state changed: $state');
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    _peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    _peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      _remoteStream = stream;
      _onAddRemoteStream?.call(stream);
    };
  }

  Future<void> disconnect() async {
    await _socketWorker?.close();
    _socketWorker = null;

    for (var track in _remoteStream?.getTracks() ?? []) {
      await track.stop();
    }

    await _peerConnection?.close();
  }

  Future<void> connect() async {
    _socketWorker = WebSocketWorker(_url);

    _socketWorker?.onOpen = () {
      print('onOpen');

      _send({'command': 'request_offer'});
    };

    _socketWorker?.onMessage = (message) {
      print('Received data: ' + message);
      onMessage(jsonDecode(message));
    };

    _socketWorker?.onClose = (int? code, String? reason) {
      print('Closed by server [$code => $reason]!');
      _sessionId = null;
    };

    await _socketWorker?.connect();
  }

  void _send(Map<String, dynamic> data) {
    _socketWorker?.send(jsonEncode(data));
  }

  void onMessage(message) async {
    switch (message['command']) {
      case 'offer':
        await _onOffer(message);
        break;
      default:
        print('Unrecognized message: $message');
        break;
    }
  }

  Future<void> _onOffer(message) async {
    _sessionId = message['id'];
    _peerId = message['peer_id'];

    var config = {'iceServers': message['iceServers']};
    print(config);
    _peerConnection = await createPeerConnection(config);

    registerPeerConnectionListeners();

    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(message['sdp']['sdp'], message['sdp']['type']),
    );

    var answer =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});
    print('Created Answer $answer');

    await _peerConnection!.setLocalDescription(answer);

    var candidates = message['candidates'];
    for (var c in candidates) {
      print(c);
      _peerConnection?.addCandidate(
        RTCIceCandidate(
            c['candidate'] ?? '', c['sdpMid'] ?? '', c['sdpMLineIndex'] ?? 0),
      );
    }

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        _remoteStream?.addTrack(track);
      });
    };

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      _send({
        'command': 'candidate',
        'candidates': [candidate.toMap()],
        'id': _sessionId,
        'peer_id': _peerId ?? 0
      });
    };

    _send({
      'command': 'answer',
      'id': _sessionId,
      'peer_id': _peerId ?? 0,
      'sdp': {'type': answer.type, 'sdp': answer.sdp}
    });
  }
}
