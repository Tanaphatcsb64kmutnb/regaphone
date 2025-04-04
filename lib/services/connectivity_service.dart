import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>>
      _subscription; // แก้ไขตรงนี้
  final _isConnectedController = StreamController<bool>.broadcast();

  Stream<bool> get isConnected => _isConnectedController.stream;
  bool _lastKnownState = true;
  bool get lastKnownState => _lastKnownState;

  void initialize() {
    _checkConnectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isConnectedController.add(false);
      _lastKnownState = false;
    }
  }

  // แก้ไขฟังก์ชันนี้
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // ถ้ามีการเชื่อมต่อใดๆ ที่ไม่ใช่ none ถือว่ามีการเชื่อมต่อ
    final isConnected =
        results.any((result) => result != ConnectivityResult.none);
    _isConnectedController.add(isConnected);
    _lastKnownState = isConnected;
  }

  void dispose() {
    _subscription.cancel();
    _isConnectedController.close();
  }

  // แก้ไขฟังก์ชันนี้
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
