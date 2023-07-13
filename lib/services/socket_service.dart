import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:band_names/auth/secrets.dart';

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket socket;

  ServerStatus get serverStatus => _serverStatus;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    socket = IO.io(url, {
      "transports": ["websocket"],
      "autoConnect": true
    });
    socket.on('connect', (_) {
      _serverStatus = ServerStatus.online;
      print("conectado");
      notifyListeners();
    });
    socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.offline;
      print("desconectado");
      notifyListeners();
    });

    // socket.on('nuevo-mensaje', (payload) {
    //   print("nuevo-mensaje:");
    //   print("nombre: ${payload["nombre"]}");
    //   print("mensaje: ${payload["mensaje"]}");
    //   print(payload.containsKey("mensaje2") ? payload["mensaje2"] : "no hay");
    // });
  }
}
