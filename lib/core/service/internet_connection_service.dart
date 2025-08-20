import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// A service to check and listen to internet connectivity status.
/// Wraps connectivity_plus for centralized network state management.
class InternetConnectionService {
  final Connectivity _connectivity = Connectivity();

  /// Stream controller to broadcast connectivity changes.
  final StreamController<bool> _connectionChangeController = StreamController<bool>.broadcast();

  InternetConnectionService() {
    // Subscribe to connectivity changes and notify listeners.
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _connectionChanged(result.first);
    });
  }

  /// Exposes stream to listen for internet connectivity changes.
  Stream<bool> get connectionChange => _connectionChangeController.stream;

  /// Checks current internet connection status.
  /// Returns true if connected to any network (wifi/mobile), false if offline.
  Future<bool> checkConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return _updateConnectionStatus(connectivityResult.first);
  }

  // Internal handler for connectivity changes.
  void _connectionChanged(ConnectivityResult result) {
    final hasConnection = _updateConnectionStatus(result);
    _connectionChangeController.add(hasConnection);
  }

  // Maps ConnectivityResult to boolean connection status.
  bool _updateConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return true;
      case ConnectivityResult.none:
      default:
        return false;
    }
  }

  /// Dispose the stream controller when not needed to avoid memory leaks.
  void dispose() {
    _connectionChangeController.close();
  }
}
