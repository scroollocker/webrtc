import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class WebSocketWorker {
  String _url;
  WebSocket? _socket;
  VoidCallback? onOpen;
  ValueChanged? onMessage;
  Function(int? code, String? reaso)? onClose;
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

  Future<void> send(data) async {
    if (_socket != null) {
      _socket?.add(data);
      print('send: $data');
    }
  }

  Future<void> close() async {
    if (_socket != null) _socket?.close();
  }
}
