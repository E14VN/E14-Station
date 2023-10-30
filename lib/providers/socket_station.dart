import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:window_manager/window_manager.dart';

class SocketStation extends ChangeNotifier {
  String url;
  late Socket socket;
  bool connected = false, socketReady = false;
  List<dynamic> emergenciesContent = [];

  SocketStation(this.url);

  establishConnection(String token) {
    try {
      socket = io(
          url,
          OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setAuth({"type": "station", "token": token})
              .build());

      socket.on("/controller/endpointsReady",
          (_) => {connectionState(true), readySocketState(true)});

      socket.on("/stationEndpoints/receive/emergenciesOverall",
          (contents) => emergenciesContentReset(contents));
      socket.on("/stationEndpoints/receive/emergencyReport",
          (content) => emergenciesContentAddOne(content));

      socket.on("reconnect", (_) => connectionState(true));
      socket.on("disconnect", (_) => connectionState(false));

      socket.connect();
    } catch (_) {
      connectionState(false);
    }
  }

  finishReport(String id) async {
    socket.emit("/stationEndpoints/emit/finishedReport", {"_id": id});
    notifyListeners();
  }

  notifyClientZone(String id) async {
    socket.emit("/stationEndpoints/emit/notifyClientZone", {"_id": id});
    notifyListeners();
  }

  readySocketState(bool state) {
    socketReady = state;
    notifyListeners();
  }

  emergenciesContentReset(List<dynamic> contents) async {
    if (!(await windowManager.isVisible()) &&
        emergenciesContent.length != contents.length) {
      windowManager.show();
    }
    emergenciesContent = contents;
    notifyListeners();
  }

  emergenciesContentAddOne(dynamic content) async {
    if (!(await windowManager.isVisible())) {
      windowManager.show();
    }
    emergenciesContent.add(content);
    notifyListeners();
  }

  connectionState(bool state) {
    connected = state;
    notifyListeners();
  }
}
