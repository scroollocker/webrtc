import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

typedef CloseSocketCallback = void Function(int? code, String? reason);
typedef OnMessageCallback = void Function(dynamic message);
typedef OnOpenCalback = void Function();

class WebSocketWorker {
  String _url;
  WebSocket? _socket;
  OnOpenCalback? onOpen;
  OnMessageCallback? onMessage;
  CloseSocketCallback? onClose;
  WebSocketWorker(this._url, {this.onOpen, this.onMessage, this.onClose});

  Future<void> connect() async {
    try {
      _socket = await WebSocket.connect(_url);
      onOpen?.call();
      _socket?.listen((data) {
        onMessage?.call(data);
      }, onDone: () {
        onClose?.call(_socket?.closeCode, _socket?.closeReason);
      });
    } catch (e) {
      onClose?.call(500, e.toString());
    }
  }

  FutureOr<void> send(data) async {
    _socket?.add(data);

    debugPrint('WebSocket - send: $data');
  }

  FutureOr<void> close() async {
    _socket?.close();
    debugPrint('WebSocket - Socket close');
  }
}
