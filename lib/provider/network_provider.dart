import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkProvider with ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  NetworkProvider() {
    _checkConnectivity();
    _listenToConnectivity();
  }

  // Connectivity check karna
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  // Connectivity listener add karna
  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
  }

  // Connection status ko update karna
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result[0] == ConnectivityResult.none) {
      _isConnected = false;
    } else {
      _isConnected = true;
    }
    notifyListeners();
  }
}
